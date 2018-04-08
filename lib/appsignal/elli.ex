defmodule Appsignal.Elli do
  @moduledoc """
  Documentation for AppsignalElli.
  """

  @behaviour :elli_handler
  @transaction Application.get_env(
                 :appsignal_elli,
                 :appsignal_transaction,
                 Appsignal.Transaction
               )

  @impl true
  def handle(_req, _args) do
    transaction =
      @transaction.generate_id()
      |> @transaction.start(:http_request)
      |> @transaction.set_action("unknown")

    Process.put(:appsignal_elli_transaction, transaction)
    :ignore
  end

  @impl true
  def handle_event(:request_complete, _data, _args) do
    transaction = Process.get(:appsignal_elli_transaction)

    if @transaction.finish(transaction) == :sample do
      # @transaction.set_request_metadata(transaction, conn)
    end

    :ok = @transaction.complete(transaction)
  end

  def handle_event(_event, _data, _args), do: :ok
end

# defmodule Appsignal.Plug.Boop do
#   def call(conn, opts) do
#     transaction =
#       @transaction.generate_id()
#       |> @transaction.start(:http_request)
#       |> Appsignal.Plug.try_set_action(conn)

#     conn = Plug.Conn.put_private(conn, :appsignal_transaction, transaction)

#     conn = super(conn, opts)
#     Appsignal.Plug.finish_with_conn(transaction, conn)
#   end

#   def finish_with_conn(transaction, conn) do
#     if @transaction.finish(transaction) == :sample do
#       @transaction.set_request_metadata(transaction, conn)
#     end

#     :ok = @transaction.complete(transaction)
#     conn
#   end

#   def try_set_action(transaction, conn) do
#     case Appsignal.Plug.extract_action(conn) do
#       nil -> transaction
#       action -> @transaction.set_action(transaction, action)
#     end
#   end

#   def extract_sample_data(
#         %Plug.Conn{
#           params: params,
#           host: host,
#           method: method,
#           script_name: script_name,
#           request_path: request_path,
#           port: port,
#           query_string: query_string
#         } = conn
#       ) do
#     %{
#       "params" => Appsignal.Utils.ParamsFilter.filter_values(params),
#       "environment" =>
#         %{
#           "host" => host,
#           "method" => method,
#           "script_name" => script_name,
#           "request_path" => request_path,
#           "port" => port,
#           "query_string" => query_string,
#           "request_uri" => url(conn),
#           "peer" => peer(conn)
#         }
#         |> Map.merge(extract_request_headers(conn))
#     }
#   end

#   @header_keys ~w(
#       accept accept-charset accept-encoding accept-language cache-control
#       connection content-length user-agent from negotiate pragma referer range

#       auth-type gateway-interface path-translated remote-host remote-ident
#       remote-user remote-addr request-method server-name server-port
#       server-protocol request-uri path-info client-ip range

#       x-request-start x-queue-start x-queue-time x-heroku-queue-wait-time
#       x-application-start x-forwarded-for x-real-ip
#     )

#   def extract_request_headers(%Plug.Conn{req_headers: req_headers}) do
#     for {key, value} <- req_headers, key in @header_keys do
#       {"req_headers.#{key}", value}
#     end
#     |> Enum.into(%{})
#   end

#   def extract_meta_data(%Plug.Conn{method: method, request_path: path} = conn) do
#     request_id =
#       conn
#       |> Plug.Conn.get_resp_header("x-request-id")
#       |> List.first()

#     %{
#       "method" => method,
#       "path" => path,
#       "request_id" => request_id
#     }
#   end

#   defp url(%Plug.Conn{scheme: scheme, host: host, port: port, request_path: request_path}) do
#     "#{scheme}://#{host}:#{port}#{request_path}"
#   end

#   defp peer(%Plug.Conn{peer: {host, port}}) do
#     "#{:inet_parse.ntoa(host)}:#{port}"
#   end
# end
