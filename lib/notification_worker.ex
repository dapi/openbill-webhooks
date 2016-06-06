defmodule OpenbillWebhooks.NotificationWorker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def fetch(server, transaction_id) do
    GenServer.call(server, {:fetch, transaction_id})
  end

  def handle_call({:fetch, transaction_id}, _from, state) do
    url = Application.get_env(:openbill_webhooks, :url)
    timeout = Application.get_env(:openbill_webhooks, :http_response_timeout_ms)
    body = "transaction_id=#{transaction_id}"

    run = fn(attempt, self) ->
      sleep = :erlang.round((1 + :random.uniform) * 10 * :math.pow(2, attempt)) * 1000

      if retries_exceeded?(attempt, url, transaction_id) do
        {:reply, "retries exceeded", state}
      else
        try do
          response = HTTPotion.post(url, [body: body,
                                          headers: ["Content-Type": "application/x-www-form-urlencoded"],
                                          timeout: timeout])

          handle_response response, url, transaction_id
          {:reply, "success", state}
        rescue
          err ->
            Logger.error("#{err.message} Retry attempt: ##{attempt} in #{sleep} ms", pid: Kernel.self(), url: url, transaction_id: transaction_id)
            :timer.sleep(sleep)
            self.(attempt + 1, self)
        end
      end
    end

    run.(1, run)
  end

  defp retries_exceeded?(attempt, url, transaction_id) do
    if attempt >= Application.get_env(:openbill_webhooks, :max_retries) do
      Logger.error("Retries exceeded", pid: Kernel.self(), url: url, transaction_id: transaction_id)
      true
    else
      false
    end
  end

  defp handle_response(response, url, transaction_id) do
    success_http_status = Application.get_env(:openbill_webhooks, :success_http_status)
    success_http_body = Application.get_env(:openbill_webhooks, :success_http_body)

    if response.status_code == success_http_status do
      # if response.body == success_http_body do
      Logger.info("Notified", pid: Kernel.self(), url: url, transaction_id: transaction_id)
    else
      # TODO: maybe retry
      Logger.error("Invalid status", pid: Kernel.self(), url: url, transaction_id: transaction_id, status: response.status_code)
    end
  end
end
