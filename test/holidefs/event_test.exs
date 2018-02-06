defmodule Holidefs.HolidayTest do
  use ExUnit.Case
  alias Holidefs.Definition.Rule
  alias Holidefs.Holiday

  doctest Holiday

  test "from_rule/2 returns a holiday from a rule and year" do
    rule = %Rule{name: "Christmas", month: 12, day: 25}
    assert [%Holiday{} = holiday] = Holiday.from_rule(:us, rule, 2017)
    assert holiday.name == "Christmas"
    assert holiday.date == ~D[2017-12-25]

    rule = %Rule{name: "Test 1", month: 7, week: -1, weekday: 3}
    assert [%Holiday{} = holiday] = Holiday.from_rule(:us, rule, 2017)
    assert holiday.date == ~D[2017-07-26]
  end
end
