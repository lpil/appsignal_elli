defmodule Appsignal.ElliTest do
  use ExUnit.Case
  doctest Appsignal.Elli
  alias Appsignal.FakeTransaction

  setup_all do
    elli_opts = [
      port: 7132,
      callback: :elli_middleware,
      callback_args: [
        mods: [
          {Appsignal.Elli, []}
        ]
      ]
    ]

    {:ok, _elli} = :elli.start_link(elli_opts)
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  setup ctx do
    FakeTransaction.reset(ctx.fake_transaction)
    :ok
  end

  describe "for a :sample transaction" do
    setup do
      assert {:ok, resp} = HTTPoison.get("localhost:7132")

      # Give time for async processing to complete
      Process.sleep(20)

      [resp: resp]
    end

    test "response", ctx do
      assert ctx.resp.status_code == 404
      assert ctx.resp.body == "Not Found"
      assert ctx.resp.headers == [{"Connection", "Keep-Alive"}, {"Content-Length", "9"}]
    end

    test "starts a transaction", ctx do
      assert FakeTransaction.started_transaction?(ctx.fake_transaction)
    end

    test "sets the transaction's action name", ctx do
      assert "unknown" == FakeTransaction.action(ctx.fake_transaction)
    end

    test "finishes the transaction", ctx do
      assert [%Appsignal.Transaction{}] =
               FakeTransaction.finished_transactions(ctx.fake_transaction)
    end

    #     test "sets the transaction's request metadata", %{
    #       conn: conn,
    #       fake_transaction: fake_transaction
    #     } do
    #       assert conn == FakeTransaction.request_metadata(fake_transaction)
    #     end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions(fake_transaction)
    end
  end

  describe "for a :no_sample transaction" do
    setup %{fake_transaction: fake_transaction} do
      FakeTransaction.update(fake_transaction, :finish, :no_sample)
      assert {:ok, resp} = HTTPoison.get("localhost:7132")

      # Give time for async processing to complete
      Process.sleep(20)

      [resp: resp]
    end

    test "does not set the transaction's request metadata", %{fake_transaction: fake_transaction} do
      assert nil == FakeTransaction.request_metadata(fake_transaction)
    end
  end
end

#   describe "extracting sample data" do
#     setup do
#       %{
#         conn: %Plug.Conn{
#           params: %{"foo" => "bar"},
#           host: "www.example.com",
#           method: "GET",
#           script_name: ["foo", "bar"],
#           request_path: "/foo/bar",
#           port: 80,
#           query_string: "foo=bar",
#           peer: {{127, 0, 0, 1}, 12345},
#           scheme: :http,
#           req_headers: [{"accept", "text/html"}]
#         }
#       }
#     end

#     test "from a Plug conn", %{conn: conn} do
#       assert Appsignal.Plug.extract_sample_data(conn) == %{
#                "params" => %{"foo" => "bar"},
#                "environment" => %{
#                  "host" => "www.example.com",
#                  "method" => "GET",
#                  "script_name" => ["foo", "bar"],
#                  "request_path" => "/foo/bar",
#                  "port" => 80,
#                  "query_string" => "foo=bar",
#                  "peer" => "127.0.0.1:12345",
#                  "request_uri" => "http://www.example.com:80/foo/bar",
#                  "req_headers.accept" => "text/html"
#                }
#              }
#     end

#     test "with a param that should be filtered out", %{conn: conn} do
#       AppsignalTest.Utils.with_config(%{filter_parameters: ["password"]}, fn ->
#         conn = %{conn | params: %{"password" => "secret"}}

#         assert %{"params" => %{"password" => "[FILTERED]"}} =
#                  Appsignal.Plug.extract_sample_data(conn)
#       end)
#     end
#   end

#   describe "extracting request headers" do
#     test "from a Plug conn" do
#       conn = %Plug.Conn{
#         req_headers: [
#           {"content-length", "1024"},
#           {"accept", "text/html"},
#           {"accept-charset", "utf-8"},
#           {"accept-encoding", "gzip, deflate"},
#           {"accept-language", "en-us"},
#           {"cache-control", "no-cache"},
#           {"connection", "keep-alive"},
#           {"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3..."},
#           {"from", "webmaster@example.org"},
#           {"referer", "http://localhost:4001/"},
#           {"range", "bytes=0-1023"},
#           {"cookie", "__ar_v4=U35IKTLTJNEP7GWW6OH3N2%3A20161120%3A90%7CI..."},
#           {"x-real-ip", "179.146.231.170"}
#         ]
#       }

#       assert Appsignal.Plug.extract_request_headers(conn) == %{
#                "req_headers.content-length" => "1024",
#                "req_headers.accept" => "text/html",
#                "req_headers.accept-charset" => "utf-8",
#                "req_headers.accept-encoding" => "gzip, deflate",
#                "req_headers.accept-language" => "en-us",
#                "req_headers.cache-control" => "no-cache",
#                "req_headers.connection" => "keep-alive",
#                "req_headers.user-agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3...",
#                "req_headers.from" => "webmaster@example.org",
#                "req_headers.referer" => "http://localhost:4001/",
#                "req_headers.range" => "bytes=0-1023",
#                "req_headers.x-real-ip" => "179.146.231.170"
#              }
#     end
#   end
