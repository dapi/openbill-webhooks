defmodule OpenbillWebhooks.TransactionListener do
  use Boltun, otp_app: :openbill_webhooks
  require Logger

  listen do
    channel Application.get_env(:openbill_webhooks, :channel), :handle_pg_notification
  end

  def handle_pg_notification(_channel, transaction_id) do
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
