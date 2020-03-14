defmodule Riptide.Interceptor do
  def before_mutation(mutation, state) do
    mutation
    |> trigger_interceptors(Riptide.Config.riptide_interceptors(), :before_mutation, [
      mutation,
      state
    ])
    |> Enum.reduce_while({:ok, mutation}, fn {mod, item}, {:ok, collect} ->
      case item do
        :ok ->
          {:cont, {:ok, collect}}

        {:combine, next} ->
          {:cont, {:ok, Riptide.Mutation.combine(collect, next)}}

        result = {:error, _} ->
          {:halt, result}

        _ ->
          {:halt, {:error, {:invalid_interceptor, mod}}}
      end
    end)
  end

  defp trigger_interceptors(mut, interceptors, fun, args) do
    mut
    |> Riptide.Mutation.layers()
    |> Stream.flat_map(&trigger_layer(&1, interceptors, fun, args))
  end

  defp trigger_layer({path, data}, interceptors, fun, args) do
    interceptors
    |> Stream.map(fn mod -> {mod, apply(mod, fun, [path, data | args])} end)
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
      def resolve_path(_path, _opts, _state), do: nil
      def before_mutation(_path, _layer, _mutation, _state), do: :ok
      def effect(_path, _layer, _mutation, _state), do: :ok
    end
  end
end

defmodule Riptide.Interceptor.Sample do
  use Riptide.Interceptor

  def before_mutation(["animals"], layer, _mut, _state) do
    {:combine, Riptide.Mutation.merge(["creates"], layer.merge)}
  end
end
