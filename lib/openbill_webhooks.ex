defmodule OpenbillWebhooks do
  alias OpenbillWebhooks.NotificationWorker
  alias OpenbillWebhooks.Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    create_logs_table

    pool_name = Application.get_env(:openbill_webhooks, :pool_name)
    poolboy_config = [
      {:name, {:local, pool_name}},
      {:worker_module, NotificationWorker},
      {:size, Application.get_env(:openbill_webhooks, :pool_size)},
      {:max_overflow, Application.get_env(:openbill_webhooks, :pool_max_overflow)}
    ]

    children = [
      # Define workers and child supervisors to be supervised
      worker(OpenbillWebhooks.TransactionListener, []),
      :poolboy.child_spec(pool_name, poolboy_config, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpenbillWebhooks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def db_connect do
    settings = Application.get_env(:openbill_webhooks, OpenbillWebhooks.TransactionListener)
    Postgrex.start_link settings
  end

  defp create_logs_table do
    {:ok, pid} = OpenbillWebhooks.db_connect
    Logger.create_table pid
  end
end
