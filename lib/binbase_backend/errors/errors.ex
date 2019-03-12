defmodule BinbaseBackend.Errors do

"""
  @code_list [
    "internet_error",
    "bad_params",
    "not_found",
    "invalid_captcha",
    "invalid_auth",
    "empty_return",
  ]
  def getCode(str) do
    Enum.find_index(@code_list, fn(x) -> x == str end)
  end
  "err_code" => getCode(str),
"""

  def returnCode(str \\ "empty_return") do
    {:error, %{"err_msg" => str} }
  end
  def returnCodeBare(str \\ "empty_return") do
    %{"err_msg" => str}
  end
end
