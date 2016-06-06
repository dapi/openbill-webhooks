use Mix.Config
config :openbill_webhooks, http_response_timeout_ms: 3000
config :openbill_webhooks, max_retries: 3
config :openbill_webhooks, minimal_try_timeout_min: 1
config :openbill_webhooks, maximal_try_timeout_min: 3600
config :openbill_webhooks, url: "http://api.kiiiosk.ru/v1/callbacks/openbill" # "http://localhost:3000"
config :openbill_webhooks, success_http_status: 200
config :openbill_webhooks, success_http_body: "success"
config :openbill_webhooks, channel: "openbill_transactions"
config :openbill_webhooks, pool_name: :pg_notification_workers_pool
config :openbill_webhooks, pool_size: 10
config :openbill_webhooks, pool_max_overflow: 20
config :openbill_webhooks, OpenbillWebhooks.TransactionListener,
  database: "${PGDATABASE}",
  username: "${PGUSER}",
  password: "${PGPASSWORD}",
  hostname: "${PGHOST}",
  port: 5432
  # TODO: как-то привести типы
  # port: "${PGPORT}" || 5432,
  # ssl: "${PGREQUIRESSL}"

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_file_logger},
             {LoggerFileBackend, :info_file_logger}]

config :logger, :error_file_logger,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:url, :transaction_id, :status],
  path: "/var/log/openbill-webhooks/error.log",
  level: :error

config :logger, :info_file_logger,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:url, :transaction_id],
  path: "/var/log/openbill-webhooks/info.log",
  level: :info
