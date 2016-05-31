# openbill-webhooks

Web-hooks server for openbill


## Configure

* http_response_timeout_ms - 3000 (3 сек)
* minimal_try_timeout_ms - (1 минута)
* maximal_try_timeout_ms (24 часа)
* database

## Tables

`openbill_webhooks`

* url - varchar(2049) ('http://api.kiiiosk.ru/billing_hook')
* success_http_status - integer (default 200)
* success_http_body - varchar (500), default ('success')

`openbill_webhooks_tries`

* webhook_id
* created_at
* transaction_id
* try (1..)

* response_http_status
* response_http_restrict_body varchar(500)
* finished_at

* is_success

## Installation
https://github.com/kerl/kerl
`brew install erlang`

https://github.com/taylor/kiex
`kiex install 1.2.5`

## Deps
```
mix deps.get
npm install
```

## Dev
```
cp config/dev_example.exs config/dev.exs
iex -S mix
node server.js
psql> notify my_channel, 'payload';
```

## Release
```
cp config/dev_example.exs config/prod.exs
MIX_ENV=prod mix release
```
