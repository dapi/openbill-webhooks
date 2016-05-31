defmodule OpenbillWebhooks.TransactionListener do
  use Boltun, otp_app: :openbill_webhooks

  listen do
    channel Application.get_env(:openbill_webhooks, :channel), :invoke_webhook
  end

  def invoke_webhook(_channel, payload) do
    url = Application.get_env(:openbill_webhooks, :url)
    success_http_status = Application.get_env(:openbill_webhooks, :success_http_status)
    success_http_body = Application.get_env(:openbill_webhooks, :success_http_body)

    response = HTTPotion.post(url, [body: "{\"transaction_id\":\"#{payload}\"}", headers: ["Content-Type": "application/json"]])

    if response.status_code == success_http_status do
      IO.puts response.body == success_http_body
    else
      # retry
      IO.puts false
    end
  end
end
