defmodule XHTTP.Transport do
  @type state() :: term()

  @type error() :: {:error, reason :: term()}

  @callback connect(host :: String.t(), port :: :inet.port_number(), opts :: keyword()) ::
              {:ok, state()} | error()

  @callback negotiated_protocol(state()) :: {:ok, protocol :: binary()} | error()

  @callback send(state(), payload :: iodata()) :: {:ok, state()} | error()

  @callback close(state()) :: {:ok, state()} | error()

  @callback recv(state(), bytes :: non_neg_integer()) :: {:ok, binary(), state()} | error()

  @callback setopts(state(), opts :: keyword()) :: :ok | error()

  @callback getopts(state(), opts :: keyword()) :: {:ok, opts :: keyword()} | error()

  @optional_callbacks [negotiated_protocol: 1]
end
