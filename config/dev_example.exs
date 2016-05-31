use Mix.Config
config :openbill_webhooks, http_response_timeout_ms: 3000
config :openbill_webhooks, minimal_try_timeout_min: 1
config :openbill_webhooks, maximal_try_timeout_min: 3600
config :openbill_webhooks, url: "http://localhost:3000/"
config :openbill_webhooks, success_http_status: 200
config :openbill_webhooks, success_http_body: "password"
config :openbill_webhooks, channel: "my_channel"
config :openbill_webhooks, OpenbillWebhooks.TransactionListener, database: "bml_development", username: "postgres", password: "", hostname: "localhost"
