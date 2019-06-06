defmodule Exchange.Errors do

  def returnCode(str \\ "empty_return") do
    {:error, %{"err_msg" => str} }
  end
  def returnCodeBare(str \\ "empty_return") do
    %{"err_msg" => str}
  end
end
