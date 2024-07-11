defmodule Holidefs.Definition.RuleTest do
  use ExUnit.Case
  alias Holidefs.Definition.Rule
  alias Holidefs.Exceptions.{FunctionNotDefinedError, InvalidRuleMapError}

  doctest Rule

  describe "build/2" do
    test "buils the definition for a valid rule map" do
      assert %Rule{} =
               rule = Rule.build(:us, 0, %{"name" => "Passover", "function" => "easter(year)"})

      assert rule.month == 0
      assert rule.name == "Passover"
      assert rule.function == :easter

      assert %Rule{} = rule = Rule.build(:us, 6, %{"name" => "Bday", "mday" => 20})

      assert rule.month == 6
      assert rule.name == "Bday"
      assert rule.day == 20

      assert %Rule{} = rule = Rule.build(:us, 6, %{"name" => "Monday", "week" => 1, "wday" => 1})

      assert rule.month == 6
      assert rule.name == "Monday"
      assert rule.week == 1
      assert rule.weekday == 1
    end

    test "returns error tuple for an invalid rule map" do
      assert_raise FunctionClauseError, fn ->
        Rule.build(:us, 0, %{"no_name" => "Bad"})
      end

      assert_raise InvalidRuleMapError, fn ->
        Rule.build(:us, 0, %{"name" => "Bad"})
      end

      assert_raise FunctionNotDefinedError, fn ->
        Rule.build(:us, 0, %{"name" => "Bad", "function" => "no_function()"})
      end
    end

    test "check the valid weekdays" do
      for i <- 1..7 do
        assert %Rule{} = Rule.build(:us, 1, %{"name" => "Weekday test", "week" => 1, "wday" => i})
      end

      assert %Rule{weekday: weekday} =
               Rule.build(:us, 1, %{"name" => "Weekday test", "week" => 1, "wday" => 0})

      assert weekday == 7

      assert_raise FunctionClauseError, fn ->
        Rule.build(:us, 1, %{"name" => "Weekday test", "week" => 1, "wday" => 8})
      end
    end
  end
end
