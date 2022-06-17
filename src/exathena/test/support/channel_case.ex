defmodule ExAthenaWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ExAthenaWeb.ChannelCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      import Assertions
      import ExAthena.Factory
      import ExAthena.TimeHelper
      import ExAthena.Factory
      import ExAthenaWeb.SocketHelper
      import Mox
      import Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint ExAthenaWeb.Endpoint
    end
  end

  setup tags do
    pid_main = Ecto.Adapters.SQL.Sandbox.start_owner!(ExAthena.Repo, shared: not tags[:async])

    pid_logger =
      Ecto.Adapters.SQL.Sandbox.start_owner!(ExAthenaLogger.Repo, shared: not tags[:async])

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid_main)
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid_logger)
    end)

    :ok
  end
end
