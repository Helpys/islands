defmodule Demo do
  defstruct [:x, :y]
end

defmodule UpdateInTest do
  use ExUnit.Case

  test "simple" do
    a = %Demo{x: 1, y: 7}
    b = update_in(a.x, &(&1 + 1))
    assert b.x == 2
  end
end
