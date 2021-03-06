defmodule XHTTPN.IntegrationTest do
  use ExUnit.Case, async: true
  alias XHTTPN.Conn

  @moduletag :integration

  describe "httpbin.org" do
    test "SSL - select HTTP1" do
      assert {:ok, conn} =
               Conn.connect(
                 "httpbin.org",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [cacertfile: "test/support/cacerts.pem"]
               )

      assert {:ok, conn, request} = Conn.request(conn, "GET", "/bytes/1", [], nil)
      assert {:ok, _conn, responses} = XHTTP1.TestHelpers.receive_stream(conn)

      assert [
               {:status, ^request, 200},
               {:headers, ^request, _},
               {:data, ^request, <<_>>},
               {:done, ^request}
             ] = responses
    end

    @tag :capture_log
    test "SSL - fail to select HTTP2" do
      assert {:error, {:tls_alert, 'no application protocol'}} =
               Conn.connect(
                 "httpbin.org",
                 443,
                 transport: XHTTP.Transport.SSL,
                 protocols: [:http2],
                 transport_opts: [cacertfile: "test/support/cacerts.pem"]
               )
    end
  end

  describe "nghttp2.org" do
    test "SSL - select HTTP1" do
      assert {:ok, conn} =
               Conn.connect(
                 "nghttp2.org",
                 443,
                 transport: XHTTP.Transport.SSL,
                 protocols: [:http1],
                 transport_opts: [verify: :verify_none]
               )

      assert {:ok, conn, request} = Conn.request(conn, "GET", "/httpbin/bytes/1", [], nil)
      assert {:ok, _conn, responses} = XHTTP1.TestHelpers.receive_stream(conn)

      assert [
               {:status, ^request, 200},
               {:headers, ^request, _},
               {:data, ^request, <<_>>},
               {:done, ^request}
             ] = responses
    end

    test "SSL - select HTTP2" do
      assert {:ok, conn} =
               Conn.connect(
                 "nghttp2.org",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [verify: :verify_none]
               )

      assert {:ok, conn, request} = Conn.request(conn, "GET", "/httpbin/bytes/1", [], nil)
      assert {:ok, _conn, responses} = XHTTP2.TestHelpers.receive_stream(conn)

      assert [
               {:status, ^request, 200},
               {:headers, ^request, _},
               {:data, ^request, <<_>>},
               {:done, ^request}
             ] = responses

      # TODO: Should we support HTTP2 throught HTTPN?
      # assert {:ok, conn, ref} = Conn.ping(conn)
      # assert {:ok, conn, [{:pong, ^ref}]} = XHTTP2.TestHelpers.receive_stream(conn)
    end
  end

  describe "ssl certificate verification" do
    test "bad certificate - badssl.com" do
      assert {:error, {:tls_alert, 'unknown ca'}} =
               Conn.connect(
                 "untrusted-root.badssl.com",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [cacertfile: "test/support/cacerts.pem", log_alert: false]
               )

      assert {:ok, _conn} =
               Conn.connect(
                 "untrusted-root.badssl.com",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [verify: :verify_none]
               )
    end

    test "bad hostname - badssl.com" do
      assert {:error, {:tls_alert, 'handshake failure'}} =
               Conn.connect(
                 "wrong.host.badssl.com",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [cacertfile: "test/support/cacerts.pem", log_alert: false]
               )

      assert {:ok, _conn} =
               Conn.connect(
                 "wrong.host.badssl.com",
                 443,
                 transport: XHTTP.Transport.SSL,
                 transport_opts: [verify: :verify_none]
               )
    end
  end
end
