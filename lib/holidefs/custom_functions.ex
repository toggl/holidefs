defmodule Holidefs.CustomFunctions do
  @moduledoc """
  These are the functions that can be used on the definition rules
  """

  alias Holidefs.DateCalculator
  alias Holidefs.Definition.Rule

  def easter(year, _) do
    DateCalculator.gregorian_easter(year)
  end

  def orthodox_easter(year, _) do
    DateCalculator.gregorian_orthodox_easter(year)
  end

  def us_inauguration_day(year, rule) when rem(year, 4) == 1 do
    {:ok, date} = Date.new(year, rule.month, 20)
    date
  end

  def us_inauguration_day(_, _) do
    nil
  end

  def lee_jackson_day(year, rule) do
    %Date{day: day_of_holiday} = DateCalculator.nth_day_of_week(year, rule.month, 3, 1)
    {:ok, king_day} = Date.new(year, rule.month, day_of_holiday)
    DateCalculator.previous_day_of_week(king_day, 5)
  end

  def georgia_state_holiday(year, rule) do
    {:ok, state_holiday} = Date.new(year, rule.month, 26)
    DateCalculator.previous_day_of_week(state_holiday, 1)
  end

  def rosh_hashanah(year, _) do
    map = %{
      2014 => ~D[2014-09-25],
      2015 => ~D[2015-09-14],
      2016 => ~D[2016-10-03],
      2017 => ~D[2017-09-21],
      2018 => ~D[2018-09-10],
      2019 => ~D[2019-09-30],
      2020 => ~D[2020-09-19]
    }

    map[year]
  end

  def yom_kippur(year, _) do
    map = %{
      2014 => ~D[2014-10-04],
      2015 => ~D[2015-09-23],
      2016 => ~D[2016-10-12],
      2017 => ~D[2017-09-30],
      2018 => ~D[2018-09-19],
      2019 => ~D[2019-10-09],
      2020 => ~D[2020-09-28]
    }

    map[year]
  end

  def election_day(year, _) do
    year
    |> DateCalculator.nth_day_of_week(11, 1, 1)
    |> Date.add(1)
  end

  def day_after_thanksgiving(year, _) do
    year
    |> DateCalculator.nth_day_of_week(11, 4, 4)
    |> Date.add(1)
  end

  def to_weekday_if_weekend(%Date{} = date, _) do
    case Date.day_of_week(date) do
      6 -> Date.add(date, -1)
      7 -> Date.add(date, 1)
      _ -> date
    end
  end

  def to_weekday_if_weekend(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)
    to_weekday_if_weekend(date, nil)
  end

  def to_tuesday_if_sunday_or_monday_if_saturday(%Date{} = date, _) do
    case Date.day_of_week(date) do
      wday when wday in 6..7 -> Date.add(date, 2)
      _ -> date
    end
  end

  def to_tuesday_if_sunday_or_monday_if_saturday(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)
    to_tuesday_if_sunday_or_monday_if_saturday(date, nil)
  end

  def to_monday_if_sunday(%Date{} = date, _) do
    case Date.day_of_week(date) do
      7 -> Date.add(date, 1)
      _ -> date
    end
  end

  def to_monday_if_sunday(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)
    to_monday_if_sunday(date, nil)
  end

  def christmas_eve_holiday(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)

    if Date.day_of_week(date) in [6, 7] do
      DateCalculator.previous_day_of_week(date, 5)
    else
      date
    end
  end

  def to_monday_if_weekend(%Date{} = date, _) do
    if Date.day_of_week(date) in [6, 7] do
      DateCalculator.next_day_of_week(date, 1)
    else
      date
    end
  end

  def to_monday_if_weekend(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)
    to_monday_if_weekend(date, nil)
  end

  def march_pub_hol_sa(year, _) do
    if year >= 2006, do: DateCalculator.nth_day_of_week(year, 3, 2, 1)
  end

  def qld_labour_day_may(year, _) do
    if year not in 2013..2015, do: DateCalculator.nth_day_of_week(year, 5, 1, 1)
  end

  def may_pub_hol_sa(year, _) do
    if year < 2006, do: DateCalculator.nth_day_of_week(year, 5, 3, 1)
  end

  def qld_queens_birthday_june(2012, _) do
    [DateCalculator.nth_day_of_week(2012, 6, 2, 1), ~D[2012-10-01]]
  end

  def qld_queens_birthday_june(year, _) when year <= 2015 do
    DateCalculator.nth_day_of_week(year, 6, 2, 1)
  end

  def qld_queens_birthday_june(_, _) do
    nil
  end

  def afl_grand_final(year, _) do
    dates = %{
      2015 => ~D[2015-10-02],
      2016 => ~D[2016-09-30],
      2017 => ~D[2017-09-29]
    }

    dates[year]
  end

  def qld_labour_day_october(year, _) do
    if year in 2014..2015, do: DateCalculator.nth_day_of_week(year, 10, 1, 1)
  end

  def qld_queens_bday_october(year, _) do
    if year >= 2016, do: DateCalculator.nth_day_of_week(year, 10, 1, 1)
  end

  def hobart_show_day(year, _) do
    fourth_sat_in_oct = DateCalculator.nth_day_of_week(year, 10, 4, 6)
    Date.add(fourth_sat_in_oct, -2)
  end

  def g20_day_2014_only(2014, _), do: ~D[2014-11-14]
  def g20_day_2014_only(_, _), do: nil

  def to_weekday_if_boxing_weekend(%Date{} = date, _) do
    if Date.day_of_week(date) in 6..7 do
      Date.add(date, 2)
    else
      date
    end
  end

  def to_weekday_if_boxing_weekend_from_year(year, _) do
    {:ok, boxing} = Date.new(year, 12, 26)

    if Date.day_of_week(boxing) in 6..7 do
      Date.add(boxing, 2)
    else
      boxing
    end
  end

  def to_weekday_if_boxing_weekend_from_year_or_to_tuesday_if_monday(year, _) do
    {:ok, boxing} = Date.new(year, 12, 26)

    case Date.day_of_week(boxing) do
      wday when wday in 6..7 -> Date.add(boxing, 2)
      1 -> Date.add(boxing, 1)
      _ -> boxing
    end
  end

  def ca_victoria_day(year, _) do
    {:ok, date} = Date.new(year, 5, 24)
    DateCalculator.previous_day_of_week(date, 1)
  end

  def ch_vd_lundi_du_jeune_federal(year, _) do
    year
    |> DateCalculator.nth_day_of_week(9, 3, 7)
    |> DateCalculator.next_day_of_week(1)
  end

  def ch_ge_jeune_genevois(year, _) do
    year
    |> DateCalculator.nth_day_of_week(9, 1, 7)
    |> DateCalculator.next_day_of_week(4)
  end

  def ch_gl_naefelser_fahrt(year, _) do
    thursday = DateCalculator.nth_day_of_week(year, 4, 1, 4)

    easter_thursday =
      year
      |> DateCalculator.gregorian_easter()
      |> DateCalculator.previous_day_of_week(4)

    if thursday == easter_thursday do
      Date.add(thursday, 7)
    else
      thursday
    end
  end

  def de_buss_und_bettag(year, _) do
    {:ok, date} = Date.new(year, 11, 23)

    if Date.day_of_week(date) == 3 do
      Date.add(date, -7)
    else
      DateCalculator.previous_day_of_week(date, 3)
    end
  end

  def fi_pyhainpaiva(year, _) do
    {:ok, date} = Date.new(year, 10, 31)
    DateCalculator.next_day_of_week(date, 6)
  end

  def fi_juhannusaatto(year, _) do
    {:ok, date} = Date.new(year, 6, 19)
    DateCalculator.next_day_of_week(date, 5)
  end

  def fi_juhannuspaiva(year, _) do
    {:ok, date} = Date.new(year, 6, 20)
    DateCalculator.next_day_of_week(date, 6)
  end

  def ph_heroes_day(year, _) do
    DateCalculator.nth_day_of_week(year, 8, -1, 1)
  end

  def pl_trzech_kroli_informal(year, _) do
    if year < 2011 do
      {:ok, date} = Date.new(year, 1, 6)
      date
    else
      nil
    end
  end

  def pl_trzech_kroli(year, _) do
    if year >= 2011 do
      {:ok, date} = Date.new(year, 1, 6)
      date
    else
      nil
    end
  end

  def se_midsommardagen(year, _) do
    {:ok, date} = Date.new(year, 6, 20)
    DateCalculator.next_day_of_week(date, 6)
  end

  def se_alla_helgons_dag(year, _) do
    {:ok, date} = Date.new(year, 10, 31)
    DateCalculator.next_day_of_week(date, 6)
  end
end
