defmodule Holidefs.Definition.RuleTest do
  use ExUnit.Case
  alias Holidefs.Definition.Rule

  doctest Rule

  test "build/2 buils the definition for a valid rule map" do
    assert %Rule{} = rule = Rule.build(0, %{"name" => "Passover", "function" => "easter(year)"})

    assert rule.month == 0
    assert rule.name == "Passover"
    assert is_function(rule.function)

    assert %Rule{} = rule = Rule.build(6, %{"name" => "Bday", "mday" => 20})

    assert rule.month == 6
    assert rule.name == "Bday"
    assert rule.day == 20

    assert %Rule{} =
             rule = Rule.build(6, %{"name" => "Monday's holiday", "week" => 1, "wday" => 1})

    assert rule.month == 6
    assert rule.name == "Monday's holiday"
    assert rule.week == 1
    assert rule.weekday == 1
  end

  test "build/2 returns error tuple for an invalid rule map" do
    assert_raise FunctionClauseError, fn ->
      Rule.build(0, %{"no_name" => "Bad"})
    end

    assert_raise FunctionClauseError, fn ->
      Rule.build(0, %{"name" => "Bad"})
    end

    assert_raise FunctionClauseError, fn ->
      Rule.build(0, %{"name" => "Bad", "function" => "no_function()"})
    end
  end
end
