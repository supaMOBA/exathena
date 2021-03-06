defmodule ExAthenaLogger.Sql do
  @moduledoc """
  The ExAthena Logger adapter for SQL storage.
  """
  @behaviour ExAthenaLogger

  alias ExAthenaLogger.Console.AuthenticationLogger
  alias ExAthenaLogger.Repo
  alias ExAthenaLogger.Sql.AuthenticationLog

  @authentication_log_event ~w(exathena authentication log)a

  @impl true
  def handle_event(event, measurements, event_meta, _config)

  def handle_event(@authentication_log_event, measurements, event_meta, _config) do
    message = AuthenticationLogger.get_log_message(event_meta)
    metadata = AuthenticationLogger.build_metadata(measurements, event_meta)

    insert_authentication_log(event_meta, message, metadata)
  end

  defp insert_authentication_log(
         %{user: user, socket: %Phoenix.Socket{assigns: %{ip: ip}, join_ref: join_ref}},
         message,
         metadata
       ) do
    insert_to_sql(AuthenticationLog, %{
      user_id: user.id,
      join_ref: join_ref,
      ip: ip,
      message: message,
      metadata: metadata
    })
  end

  defp insert_authentication_log(
         %{socket: %Phoenix.Socket{assigns: %{ip: ip}, join_ref: join_ref}},
         message,
         metadata
       ) do
    insert_to_sql(AuthenticationLog, %{
      join_ref: join_ref,
      ip: ip,
      message: message,
      metadata: metadata
    })
  end

  defp insert_to_sql(schema, attrs) do
    schema
    |> struct!()
    |> schema.changeset(attrs)
    |> Repo.insert()
  end
end
