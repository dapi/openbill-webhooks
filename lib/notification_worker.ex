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

    try do
      response = HTTPotion.post(url, [body: body,
                                      headers: ["Content-Type": "application/x-www-form-urlencoded"],
                                      timeout: timeout])

      handle_response response, url, transaction_id
    rescue
      err ->
        # TODO: retry
        Logger.error(err.message, url: url, transaction_id: transaction_id)
    end

    {:reply, "whatever", state}
  end

  defp handle_response(response, url, transaction_id) do
    success_http_status = Application.get_env(:openbill_webhooks, :success_http_status)
    success_http_body = Application.get_env(:openbill_webhooks, :success_http_body)

    if response.status_code == success_http_status do
      # if response.body == success_http_body do
      Logger.info("Notified", url: url, transaction_id: transaction_id)
    else
      # TODO: maybe retry
      Logger.error("Invalid status", url: url, transaction_id: transaction_id, status: response.status_code)
    end
  end
end
