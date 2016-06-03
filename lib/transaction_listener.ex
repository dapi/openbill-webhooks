defmodule OpenbillWebhooks.TransactionListener do
  use Boltun, otp_app: :openbill_webhooks
  alias OpenbillWebhooks.NotificationWorker

  listen do
    channel Application.get_env(:openbill_webhooks, :channel), :handle_pg_notification
  end

  def handle_pg_notification(_channel, transaction_id) do
    spawn( fn() -> process(transaction_id) end )
  end

  def process(transaction_id) do
    pool_name = Application.get_env(:openbill_webhooks, :pool_name)
    :poolboy.transaction pool_name, fn(http_requester_pid) ->
      NotificationWorker.fetch(http_requester_pid, transaction_id)
    end
  end
end
