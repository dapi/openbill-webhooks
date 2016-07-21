defmodule OpenbillWebhooks.Logger do
  @table_name Application.get_env(:openbill_webhooks, :logs_table)

  def create_table(pid) do
    table = """
    CREATE TABLE IF NOT EXISTS #{@table_name} (
      id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      level               character varying(256) not null,
      message             character varying(256) not null,
      pid                 character varying(256) not null,
      url                 character varying(256) not null,
      transaction_id      uuid not null,
      status              character varying(256),
      created_at          timestamp without time zone default current_timestamp,
      foreign key (transaction_id) REFERENCES OPENBILL_TRANSACTIONS (id) ON DELETE CASCADE
    );
    """
    level_index = "CREATE INDEX IF NOT EXISTS #{@table_name}_on_level ON #{@table_name} USING btree (level);"
    transaction_index = "CREATE INDEX IF NOT EXISTS #{@table_name}_on_transaction_id ON #{@table_name} USING btree (transaction_id);"
    Postgrex.query!(pid, table, [])
    Postgrex.query!(pid, level_index, [])
    Postgrex.query!(pid, transaction_index, [])
  end

  def info(pid, message, payload) do
    write_log(:info, pid, message, payload)
  end

  def error(pid, message, payload) do
    write_log(:error, pid, message, payload)
  end

  defp write_log(level, pid, message, payload) do
    sql = """
    INSERT INTO #{@table_name} (level, message, pid, url, transaction_id, status)
    VALUES ('#{level}', '#{message}', '#{inspect payload.pid}', '#{payload.url}', '#{payload.transaction_id}', '#{payload.status}')
    """
    Postgrex.query!(pid, sql, [])
  end
end
