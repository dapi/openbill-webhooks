defmodule OpenbillWebhooks.NotificationWorker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def fetch(server, transaction_id) do
    GenServer.call(server, {:fetch, transaction_id})
  end

  @url Application.get_env(:openbill_webhooks, :url)
  @timeout Application.get_env(:openbill_webhooks, :http_response_timeout_ms)

  def handle_call({:fetch, transaction_id}, _from, state) do
    body = "transaction_id=#{transaction_id}"

    run = fn(attempt, self) ->
      sleep = sleep_time attempt

      try do
        response = HTTPotion.post(@url, [body: body,
                                        headers: ["Content-Type": "application/x-www-form-urlencoded"],
                                        timeout: @timeout])

        handle_response response.status_code, response.body, transaction_id
        {:reply, "success", state}
      rescue
        err ->
          Logger.error("#{err.message} Retry attempt: ##{attempt} in #{sleep} ms", pid: Kernel.self(), url: @url, transaction_id: transaction_id)
          :timer.sleep(sleep)
          self.(attempt + 1, self)
      end
    end

    run.(1, run)
  end

  @minimal_try_timeout Application.get_env(:openbill_webhooks, :minimal_try_timeout_min) * 60000
  @maximal_try_timeout Application.get_env(:openbill_webhooks, :maximal_try_timeout_min) * 60000

  defp sleep_time(attempt) do
    time = :erlang.round((1 + :random.uniform) * 10 * :math.pow(2, attempt)) * 1000
    cond do
      time < @minimal_try_timeout -> @minimal_try_timeout
      time > @maximal_try_timeout -> @maximal_try_timeout
      time -> time
    end
  end

  @success_http_status Application.get_env(:openbill_webhooks, :success_http_status)
  @success_http_body Application.get_env(:openbill_webhooks, :success_http_body)

  defp handle_response(@success_http_status, @success_http_body, transaction_id) do
    Logger.info("Notified", pid: Kernel.self(), url: @url, transaction_id: transaction_id)
  end
  defp handle_response(status, _, transaction_id) do
    Logger.error("Invalid status or body",
      pid: Kernel.self(),
      url: @url,
      transaction_id: transaction_id,
      status: status
    )
    raise InvalidStatusError
  end
end
