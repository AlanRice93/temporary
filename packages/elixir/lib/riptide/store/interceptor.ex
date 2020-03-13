defmodule Riptide.Interceptor do
  def trigger(mutation, state) do
  end

  @callback resolve_path(path :: list(String.t()), opts :: map, state :: any) ::
              {:ok, any} | {:error, term} | nil

  # @callback validate_query(
  #             path :: list(String.t()),
  #             opts :: map,
  #             query :: map,
  #             state :: String.t()
  #           ) :: :ok | {:error, term}

  # @callback validate_mutation(
  #             path :: list(String.t()),
  #             layer :: Riptide.Mutation.t(),
  #             mut :: Riptide.Mutation.t(),
  #             state :: String.t()
  #           ) :: :ok | {:error, term}

  @callback before_mutation(
              path :: list(String.t()),
              layer :: Riptide.Mutation.t(),
              mut :: Riptide.Mutation.t(),
              state :: String.t()
            ) :: :ok | {:error, term} | {:combine, Riptide.Mutation.t()}

  @callback effect(
              path :: list(String.t()),
              layer :: Riptide.Mutation.t(),
              mut :: Riptide.Mutation.t(),
              state :: String.t()
            ) :: :ok | {atom(), atom(), list(String.t())} | {atom(), list(String.t())}

  defmacro __using__(_opts) do
    quote do
      @behaviour Riptide.Interceptor
      @before_compile Riptide.Interceptor
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def resolve_path(_path, _opts, _user), do: nil
      def before_mutation(_path, _layer, _mutation, _user), do: nil
      def effect(_path, _layer, _mutation, _user), do: nil
    end
  end
end
