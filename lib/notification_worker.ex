defmodule OpenbillWebhooks.NotificationWorker do
  use GenServer
  alias OpenbillWebhooks.Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def fetch(server, transaction_id) do
    GenServer.call(server, {:fetch, transaction_id})
  end

  @url Application.get_env(:openbill_webhooks, :url)
  @timeout Application.get_env(:openbill_webhooks, :http_response_timeout_ms)

  def handle_call({:fetch, transaction_id}, _from, state) do
    {:ok, conn} = OpenbillWebhooks.db_connect

    run = fn(attempt, self) ->
      sleep = sleep_time attempt

      try do
        response = HTTPotion.post(@url, [body: "transaction_id=#{transaction_id}",
                                        headers: ["Content-Type": "application/x-www-form-urlencoded"],
                                        timeout: @timeout])

        handle_response conn, response.status_code, response.body, transaction_id
        {:reply, "success", state}
      rescue
        err ->
          Logger.error(conn, "#{err.message} Retry attempt: ##{attempt} in #{sleep / 1000} s",
            %{pid: Kernel.self(),
              url: @url,
              transaction_id: transaction_id,
              status: '',
              body: ''}
          )
          :timer.sleep(sleep)
          self.(attempt + 1, self)
      end
    end

    run.(1, run)
    # TODO: terminate callback
    OpenbillWebhooks.db_disconnect conn
  end

  @minimal_try_timeout Application.get_env(:openbill_webhooks, :minimal_try_timeout_min) * 60000
  @maximal_try_timeout Application.get_env(:openbill_webhooks, :maximal_try_timeout_min) * 60000

  defp sleep_time(attempt) do
    time = :erlang.round((1 + :random.uniform) * 10 * :math.pow(2, attempt)) * 1000
    cond do
      time < @minimal_try_timeout -> @minimal_try_timeout
      time > @maximal_try_timeout -> @maximal_try_timeout
      time -> time
    end
  end

  @success_http_status Application.get_env(:openbill_webhooks, :success_http_status)
  @success_http_body Application.get_env(:openbill_webhooks, :success_http_body)

  defp handle_response(conn, @success_http_status, @success_http_body, transaction_id) do
    Logger.info(conn, "Notified",
      %{pid: Kernel.self(),
        url: @url,
        transaction_id: transaction_id,
        status: @success_http_status,
        body: @success_http_body}
    )
  end
  defp handle_response(conn, status, body, transaction_id) do
    Logger.error(conn, "Invalid status or body",
      %{pid: Kernel.self(),
        url: @url,
        transaction_id: transaction_id,
        status: status,
        body: String.slice(body, 0..199)}
    )
    raise InvalidStatusError
  end
end
