defmodule UTTesla.RequestIdTest do
  use ExUnit.Case, async: true

  alias UTTesla.RequestId

  setup do
    [env: %Tesla.Env{}]
  end

  test "set request id", %{env: env} do
    assert {:ok, env1} = RequestId.call(env, [], [])
    assert {:ok, env2} = RequestId.call(env, [], [])

    assert [{"x-request-id", request_id1}] = env1.headers
    assert is_binary(request_id1)

    assert [{"x-request-id", request_id2}] = env2.headers
    assert is_binary(request_id2)

    assert request_id1 != request_id2
  end

  test "custom header", %{env: env} do
    assert {:ok, env1} = RequestId.call(env, [], http_header: "custom-header")
    assert [{"custom-header", _}] = env1.headers
  end

  test "custom request id", %{env: env} do
    assert {:ok, env1} = RequestId.call(env, [], request_id: "custom-id")
    assert [{"x-request-id", "custom-id"}] = env1.headers
  end
end
