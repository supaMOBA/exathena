defmodule ExAthena.Config do
  @moduledoc """
  The ExAthena Config context.

  It handles all .conf files located at `settings`
  path in root umbrella project.
  """
  use ExAthena.IO

  alias ExAthena.Config.{LoginAthena, SubnetAthena}

  @configs %{
    login_athena: [
      name: LoginAthenaConfig,
      category: :server,
      reload?: false,
      schema: LoginAthena
    ],
    subnet_athena: [
      name: SubnetAthenaConfig,
      category: :server,
      reload?: false,
      schema: SubnetAthena
    ]
  }

  # Hacky way to configure their childrens
  configure :conf do
    for {id, opts} <- @configs do
      item id, opts
    end
  end

  # Create functions with arity 0 to get the config parsed data
  for {id, opts} <- @configs do
    schema =
      opts
      |> Keyword.fetch!(:schema)
      |> Module.split()
      |> List.last()

    @doc """
    Gets the current parsed configuration state.

    ## Examples

        iex> Config.#{id}()
        {:ok, %#{schema}{}

        iex> Config.#{id}()
        {:error, :server_down}

    """
    @spec unquote(id)() :: {:ok, unquote(opts[:schema]).t()} | {:error, :server_down}
    def unquote(id)() do
      name = unquote(opts[:name])

      case GenServer.whereis(name) do
        nil -> {:error, :server_down}
        _ -> {:ok, Item.get_data(name)}
      end
    end
  end
end
