defmodule Holidefs.DefinitionTest do
  use ExUnit.Case
  alias Holidefs.Definition
  alias Holidefs.Definition.CustomFunctions

  doctest Definition

  test "load!/2 loads the given locale from the definition lib" do
    assert %Definition{} = definition = Definition.load!(:br, "Brazil")
    assert definition.code == :br
    assert definition.name == "Brazil"

    assert Enum.map(definition.rules, fn rule ->
             fun_res = if rule.function, do: CustomFunctions.call(rule.function, 2017, rule)
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

  test "load!/2 loads the given locale from the deps path" do
    assert %Definition{} = definition = Definition.load!(:br, "Brazil", :deps)
    assert definition.code == :br
    assert definition.name == "Brazil"

    assert Enum.map(definition.rules, fn rule ->
             fun_res = if rule.function, do: CustomFunctions.call(rule.function, 2017, rule)
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
             {"Dia Nacional de Zumbi e da Consciência Negra", 11, 20, nil},
             {"Natal", 12, 25, nil}
           ]
  end
end
