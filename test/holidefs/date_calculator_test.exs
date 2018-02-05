defmodule Holidefs.DateCalculatorTest do
  use ExUnit.Case
  alias Holidefs.DateCalculator

  doctest DateCalculator

  test "nth_day_of_week/4 returns the nth day of week" do
    assert DateCalculator.nth_day_of_week(2017, 7, -3, 3) == ~D[2017-07-12]
    assert DateCalculator.nth_day_of_week(2017, 11, -3, 3) == ~D[2017-11-15]
    assert DateCalculator.nth_day_of_week(2017, 7, -1, 3) == ~D[2017-07-26]
    assert DateCalculator.nth_day_of_week(2017, 11, -1, 3) == ~D[2017-11-29]
    assert DateCalculator.nth_day_of_week(2017, 4, 1, 3) == ~D[2017-04-05]
    assert DateCalculator.nth_day_of_week(2017, 3, 1, 3) == ~D[2017-03-01]
    assert DateCalculator.nth_day_of_week(2017, 4, 3, 3) == ~D[2017-04-19]
    assert DateCalculator.nth_day_of_week(2017, 3, 3, 3) == ~D[2017-03-15]
  end
end
