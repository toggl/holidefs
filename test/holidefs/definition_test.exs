defmodule Holidefs.DefinitionTest do
  use ExUnit.Case
  alias Holidefs.Definition

  doctest Definition

  test "load!/2 loads the given locale from the definition lib" do
    assert %Definition{} = definition = Definition.load!("BR", "Brazil")
    assert definition.code == "BR"
    assert definition.name == "Brazil"

    assert Enum.map(definition.rules, fn rule ->
             fun_res = if rule.function, do: rule.function.(2017, rule)
             {rule.name, rule.month, rule.day, fun_res}
           end) == [
             {"Carnaval", 0, nil, ~D[2017-02-28]},
             {"Sexta-feira Santa", 0, nil, ~D[2017-04-14]},
             {"Páscoa", 0, nil, ~D[2017-04-16]},
             {"Corpus Christi", 0, nil, ~D[2017-06-15]},
             {"Dia da Confraternização Universal", 1, 1, nil},
             {"Dia de Tiradentes", 4, 21, nil},
             {"Dia do Trabalho", 5, 1, nil},
             {"Proclamação da Independência", 9, 7, nil},
             {"Dia de Nossa Senhora Aparecida", 10, 12, nil},
             {"Dia de Finados", 11, 2, nil},
             {"Proclamação da República", 11, 15, nil},
             {"Natal", 12, 25, nil}
           ]
  end
end

defmodule Holidefs.DefinitionRuleTest do
  use ExUnit.Case
  alias Holidefs.DefinitionRule

  doctest DefinitionRule

  test "build/2 buils the definition for a valid rule map" do
    assert %DefinitionRule{} =
             rule = DefinitionRule.build(0, %{"name" => "Passover", "function" => "easter(year)"})

    assert rule.month == 0
    assert rule.name == "Passover"
    assert is_function(rule.function)

    assert %DefinitionRule{} = rule = DefinitionRule.build(6, %{"name" => "Bday", "mday" => 20})

    assert rule.month == 6
    assert rule.name == "Bday"
    assert rule.day == 20

    assert %DefinitionRule{} =
             rule =
             DefinitionRule.build(6, %{"name" => "Monday's holiday", "week" => 1, "wday" => 1})

    assert rule.month == 6
    assert rule.name == "Monday's holiday"
    assert rule.week == 1
    assert rule.weekday == 1
  end

  test "build/2 returns error tuple for an invalid rule map" do
    assert_raise FunctionClauseError, fn ->
      DefinitionRule.build(0, %{"no_name" => "Bad"})
    end

    assert_raise FunctionClauseError, fn ->
      DefinitionRule.build(0, %{"name" => "Bad"})
    end

    assert_raise FunctionClauseError, fn ->
      DefinitionRule.build(0, %{"name" => "Bad", "function" => "no_function()"})
    end
  end
end
