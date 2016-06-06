# openbill-webhooks

Web-hooks server for openbill


## Configure

* http_response_timeout_ms - 3000 (3 сек)
* minimal_try_timeout_ms - (1 минута)
* maximal_try_timeout_ms (24 часа)
* database

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
MIX_ENV=prod mix compile
MIX_ENV=prod mix release
RELX_REPLACE_OS_VARS=true PGREQUIRESSL=true PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=dbname rel/openbill_webhooks/bin/openbill_webhooks foreground
```
