use Mix.Config
config :openbill_webhooks, http_response_timeout_ms: 3000
config :openbill_webhooks, minimal_try_timeout_min: 1
config :openbill_webhooks, maximal_try_timeout_min: 1440
config :openbill_webhooks, url: "http://localhost:3000/"
config :openbill_webhooks, success_http_status: 200
config :openbill_webhooks, success_http_body: "success"
config :openbill_webhooks, channel: "openbill_transactions"
config :openbill_webhooks, pool_name: :pg_notification_workers_pool
config :openbill_webhooks, pool_size: 3
config :openbill_webhooks, pool_max_overflow: 3
config :openbill_webhooks, OpenbillWebhooks.TransactionListener,
  database: "kiiiosk_development",
  username: "postgres",
  password: "",
  hostname: "localhost"

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_file_logger},
             {LoggerFileBackend, :info_file_logger}]

config :logger, :error_file_logger,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:pid, :url, :transaction_id, :status],
  path: "./error.log",
  level: :error

config :logger, :info_file_logger,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:pid, :url, :transaction_id],
  path: "./info.log",
  level: :info
