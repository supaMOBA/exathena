defmodule ExAthena do
  @moduledoc """
  The entrypoint for defining your backend interface, such
  as contexts, schemas and so on.

  This can be used in your application as:

      use ExAthena, :context
      use ExAthena, :schema

  The definitions below will be executed for every context,
  schema, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @clock Application.compile_env(:exathena, :clock_module, ExAthena.Clock.Timex)

  def context do
    quote do
      import Ecto.Query, warn: false

      alias ExAthena.Repo
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      alias Cloak.Ecto.SHA256
      alias Ecto.Changeset
      alias ExAthena.Encrypted.Binary

      @typedoc """
      The ecto association type with required value
      """
      @type required_assoc(schema) :: schema | %{__struct__: Ecto.Association.NotLoaded}

      @typedoc """
      The ecto association type
      """
      @type assoc(schema) :: schema | %{__struct__: Ecto.Association.NotLoaded} | nil
    end
  end

  @doc """
  When used, dispatch to the appropriate context/schema/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  @doc """
  Returns the actual datetime with time zone applied.

  ## Examples

      iex> ExAthena.clock()
      ~U[2022-01-01 03:00:00Z]

      iex> ExAthena.clock(:utc)
      ~U[2022-01-01 03:00:00Z]

      iex> ExAthena.clock("America/Sao_Paulo")
      ~U[2022-01-01 00:00:00Z]

  """
  @spec now(String.t() | :utc) :: DateTime.t()
  def now(tz \\ :utc), do: @clock.now(tz)

  @doc "Checks if current server is Renewal"
  @spec renewal?() :: boolean()
  def renewal?, do: server_type() == :renewal

  @doc "Checks if current server is Pre-Renewal"
  @spec pre_renewal?() :: boolean()
  def pre_renewal?, do: server_type() == :pre_renewal

  defp server_type do
    Application.get_env(:exathena, :server_type, :renewal)
  end
end
