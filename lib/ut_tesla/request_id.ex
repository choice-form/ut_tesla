defmodule UTTesla.RequestId do
  @moduledoc """
  生成 request ID 。生成规则同 Plug.RequestId

  直接使用：

      plug UTTesla.RequestId

  自定义 header ：

      plug UTTesla.RequestId,
        http_header: "myapp-request-id",

  使用外界的 request id ，搭配自建 client 使用：

      request_id_middleware = {UTTesla.RequestId, [request_id: "custom-id"]}
      adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}
      Tesla.client([request_id_middleware], adapter)


  ## 可选参数

    * `:http_header` - 请求 header 的名称。默认值 `"x-request-id"` 。
    * `:request_id` - 自定义 request ID ，用于直接使用外部 ID 的场景。必须搭配
      自建 client 使用。否则会导致每次生成的 request ID 都是一样的。

  """
  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, opts) do
    env
    |> set_request_id(opts)
    |> Tesla.run(next)
  end

  defp set_request_id(env, opts) do
    header_name = opts[:http_header] || "x-request-id"
    request_id = opts[:request_id] || generate_request_id()
    Tesla.put_header(env, header_name, request_id)
  end

  defp generate_request_id do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.url_encode64(binary)
  end
end
