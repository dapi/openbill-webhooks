# openbill-webhooks

Web-hooks server for openbill

Docker - https://github.com/BrandyMint/docker-openbill-webhooks


## Configure

* http_response_timeout_ms - 3000 (3 сек)
* minimal_try_timeout_ms - (1 минута)
* maximal_try_timeout_ms (24 часа)
* database

## Installation

## iOS

> `brew install erlang`


## Linux

* https://github.com/kerl/kerl (Erlang Version Manager)
> kerl build 18.3 r18p3
> kerl install r18p3 ~/erlang
> ~/erlang/activate

## All

https://github.com/taylor/kiex (Elixir Version Manager)

Add ~/.kiex/bin to PATH

> kiex install 1.2.5
> kiex default 1.2.5

## Deps
```
npm install
```

## Dev
```
> cp config/dev_example.exs config/dev.exs
#  В config/dev.exs устанавливаем путь для POST-запроса config :openbill_webhooks, url: "http://localhost:3000"

> mix deps.get # Установка зависимостей
> iex -S mix # Собственно запускаем сервис

# Запускаем тестовый веб-сервер, который будет принимать запросы (http://localhost:3000)
> node test_hook_server.js

# Отправляем тестовое уведомление, где 123 - ID транзакции
> psql> notify openbill_transaction, '123';
```

## Release
```
cp config/dev_example.exs config/prod.exs
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod mix release
RELX_REPLACE_OS_VARS=true PGREQUIRESSL=true PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=dbname rel/openbill_webhooks/bin/openbill_webhooks foreground
```
