defmodule Holidefs.Definition.CustomFunctions do
  @moduledoc false

  alias Holidefs.DateCalculator
  alias Holidefs.Definition.Rule

  def call(fun, year, %Rule{function_modifier: modifier} = rule) when modifier != nil do
    case apply(__MODULE__, fun, [year, rule]) do
      %Date{} = date -> Date.add(date, modifier)
      other -> other
    end
  end

  def call(fun, year, %Rule{} = rule) do
    apply(__MODULE__, fun, [year, rule])
  end

  @doc false
  def easter(year, _) do
    DateCalculator.gregorian_easter(year)
  end

  @doc false
  def orthodox_easter(year, _) do
    DateCalculator.gregorian_orthodox_easter(year)
  end

  @doc false
  def julian_orthodox_easter(year, _) do
    DateCalculator.julian_orthodox_easter(year)
  end

  @doc false
  def orthodox_easter_julian(year, _) do
    DateCalculator.julian_orthodox_easter(year)
  end

  @doc false
  def us_inauguration_day(year, rule) when rem(year, 4) == 1 do
    {:ok, date} = Date.new(year, rule.month, 20)
    date
  end

  def us_inauguration_day(_, _) do
    nil
  end

  @doc false
  def lee_jackson_day(year, rule) do
    %Date{day: day_of_holiday} = DateCalculator.nth_day_of_week(year, rule.month, 3, 1)
    {:ok, king_day} = Date.new(year, rule.month, day_of_holiday)
    DateCalculator.previous_day_of_week(king_day, 5)
  end

  @doc false
  def georgia_state_holiday(year, rule) do
    {:ok, state_holiday} = Date.new(year, rule.month, 26)
    DateCalculator.previous_day_of_week(state_holiday, 1)
  end

  @doc false
  def rosh_hashanah(2014, _), do: ~D[2014-09-25]
  def rosh_hashanah(2015, _), do: ~D[2015-09-14]
  def rosh_hashanah(2016, _), do: ~D[2016-10-03]
  def rosh_hashanah(2017, _), do: ~D[2017-09-21]
  def rosh_hashanah(2018, _), do: ~D[2018-09-10]
  def rosh_hashanah(2019, _), do: ~D[2019-09-30]
  def rosh_hashanah(2020, _), do: ~D[2020-09-19]
  def rosh_hashanah(2021, _), do: ~D[2021-09-07]
  def rosh_hashanah(2022, _), do: ~D[2022-09-26]
  def rosh_hashanah(2023, _), do: ~D[2023-09-16]
  def rosh_hashanah(2024, _), do: ~D[2024-10-03]
  def rosh_hashanah(2025, _), do: ~D[2025-09-23]
  def rosh_hashanah(2026, _), do: ~D[2026-09-12]
  def rosh_hashanah(2027, _), do: ~D[2027-10-02]
  def rosh_hashanah(2028, _), do: ~D[2028-09-21]
  def rosh_hashanah(2029, _), do: ~D[2029-09-10]
  def rosh_hashanah(2030, _), do: ~D[2030-09-28]
  def rosh_hashanah(2031, _), do: ~D[2031-09-18]
  def rosh_hashanah(2032, _), do: ~D[2032-09-06]
  def rosh_hashanah(2033, _), do: ~D[2033-09-24]
  def rosh_hashanah(2034, _), do: ~D[2034-09-14]
  def rosh_hashanah(2035, _), do: ~D[2035-10-04]
  def rosh_hashanah(2036, _), do: ~D[2036-09-22]
  def rosh_hashanah(2037, _), do: ~D[2037-09-09]
  def rosh_hashanah(2038, _), do: ~D[2038-09-30]
  def rosh_hashanah(2039, _), do: ~D[2039-09-19]
  def rosh_hashanah(2040, _), do: ~D[2040-09-08]
  def rosh_hashanah(2041, _), do: ~D[2041-09-26]
  def rosh_hashanah(2042, _), do: ~D[2042-09-15]
  def rosh_hashanah(2043, _), do: ~D[2043-10-05]
  def rosh_hashanah(2044, _), do: ~D[2044-09-22]
  def rosh_hashanah(2045, _), do: ~D[2045-09-12]
  def rosh_hashanah(2046, _), do: ~D[2046-10-01]
  def rosh_hashanah(2047, _), do: ~D[2047-09-21]
  def rosh_hashanah(2048, _), do: ~D[2048-09-08]
  def rosh_hashanah(2049, _), do: ~D[2049-09-27]
  def rosh_hashanah(2050, _), do: ~D[2050-09-17]
  def rosh_hashanah(2051, _), do: ~D[2051-09-07]
  def rosh_hashanah(2052, _), do: ~D[2052-09-24]
  def rosh_hashanah(_, _), do: nil

  @doc false
  def yom_kippur(2014, _), do: ~D[2014-10-04]
  def yom_kippur(2015, _), do: ~D[2015-09-23]
  def yom_kippur(2016, _), do: ~D[2016-10-12]
  def yom_kippur(2017, _), do: ~D[2017-09-30]
  def yom_kippur(2018, _), do: ~D[2018-09-19]
  def yom_kippur(2019, _), do: ~D[2019-10-09]
  def yom_kippur(2020, _), do: ~D[2020-09-28]
  def yom_kippur(2021, _), do: ~D[2021-09-16]
  def yom_kippur(2022, _), do: ~D[2022-10-05]
  def yom_kippur(2023, _), do: ~D[2023-09-25]
  def yom_kippur(2024, _), do: ~D[2024-10-12]
  def yom_kippur(2025, _), do: ~D[2025-10-02]
  def yom_kippur(2026, _), do: ~D[2026-09-21]
  def yom_kippur(2027, _), do: ~D[2027-10-11]
  def yom_kippur(2028, _), do: ~D[2028-09-30]
  def yom_kippur(2029, _), do: ~D[2029-09-19]
  def yom_kippur(2030, _), do: ~D[2030-10-07]
  def yom_kippur(2031, _), do: ~D[2031-09-27]
  def yom_kippur(2032, _), do: ~D[2032-09-15]
  def yom_kippur(2033, _), do: ~D[2033-10-03]
  def yom_kippur(2034, _), do: ~D[2034-09-23]
  def yom_kippur(2035, _), do: ~D[2035-10-13]
  def yom_kippur(2036, _), do: ~D[2036-10-01]
  def yom_kippur(2037, _), do: ~D[2037-09-19]
  def yom_kippur(2038, _), do: ~D[2038-10-09]
  def yom_kippur(2039, _), do: ~D[2039-09-28]
  def yom_kippur(2040, _), do: ~D[2040-09-17]
  def yom_kippur(2041, _), do: ~D[2041-10-05]
  def yom_kippur(2042, _), do: ~D[2042-09-24]
  def yom_kippur(2043, _), do: ~D[2043-10-14]
  def yom_kippur(2044, _), do: ~D[2044-10-01]
  def yom_kippur(2045, _), do: ~D[2045-09-21]
  def yom_kippur(2046, _), do: ~D[2046-10-10]
  def yom_kippur(2047, _), do: ~D[2047-09-30]
  def yom_kippur(2048, _), do: ~D[2048-09-17]
  def yom_kippur(2049, _), do: ~D[2049-10-06]
  def yom_kippur(2050, _), do: ~D[2050-09-26]
  def yom_kippur(2051, _), do: ~D[2051-09-16]
  def yom_kippur(2052, _), do: ~D[2052-10-03]
  def yom_kippur(_, _), do: nil

  @doc false
  def matariki(2022, _), do: ~D[2022-06-24]
  def matariki(2023, _), do: ~D[2023-07-14]
  def matariki(2024, _), do: ~D[2024-06-28]
  def matariki(2025, _), do: ~D[2025-06-20]
  def matariki(2026, _), do: ~D[2026-07-10]
  def matariki(2027, _), do: ~D[2027-06-25]
  def matariki(2028, _), do: ~D[2028-07-14]
  def matariki(2029, _), do: ~D[2029-07-06]
  def matariki(2030, _), do: ~D[2030-06-21]
  def matariki(2031, _), do: ~D[2031-07-11]
  def matariki(2032, _), do: ~D[2032-07-02]
  def matariki(2033, _), do: ~D[2033-06-24]
  def matariki(2034, _), do: ~D[2034-07-07]
  def matariki(2035, _), do: ~D[2035-06-29]
  def matariki(2036, _), do: ~D[2036-07-18]
  def matariki(2037, _), do: ~D[2037-07-10]
  def matariki(2038, _), do: ~D[2038-06-25]
  def matariki(2039, _), do: ~D[2039-07-15]
  def matariki(2040, _), do: ~D[2040-07-06]
  def matariki(2041, _), do: ~D[2041-07-19]
  def matariki(2042, _), do: ~D[2042-07-11]
  def matariki(2043, _), do: ~D[2043-07-03]
  def matariki(2044, _), do: ~D[2044-06-24]
  def matariki(2045, _), do: ~D[2045-07-07]
  def matariki(2046, _), do: ~D[2046-06-29]
  def matariki(2047, _), do: ~D[2047-07-19]
  def matariki(2048, _), do: ~D[2048-07-03]
  def matariki(2049, _), do: ~D[2049-06-25]
  def matariki(2050, _), do: ~D[2050-07-15]
  def matariki(2051, _), do: ~D[2051-06-30]
  def matariki(2052, _), do: ~D[2052-06-21]
  def matariki(_, _), do: nil

  @doc false
  def election_day(year, _) do
    year
    |> DateCalculator.nth_day_of_week(11, 1, 1)
    |> Date.add(1)
  end

  @doc false
  def day_after_thanksgiving(year, _) do
    year
    |> DateCalculator.nth_day_of_week(11, 4, 4)
    |> Date.add(1)
  end

  @doc false
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

  @doc false
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

  @doc false
  def to_following_monday_if_not_monday(%Date{} = date, _) do
    case Date.day_of_week(date) do
      1 -> date
      _ -> DateCalculator.next_day_of_week(date, 1)
    end
  end

  @doc false
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

  @doc false
  def closest_monday(%Date{} = date, _) do
    case Date.day_of_week(date) do
      day when day in 1..4 -> Date.add(date, 1 - day)
      day -> Date.add(date, 8 - day)
    end
  end

  @doc false
  def previous_friday(%Date{} = date, _) do
    DateCalculator.previous_day_of_week(date, 6)
  end

  @doc false
  def next_week(%Date{} = date, _) do
    Date.add(date, 7)
  end

  @doc false
  def christmas_eve_holiday(year, %Rule{month: month, day: day}) do
    {:ok, date} = Date.new(year, month, day)

    if Date.day_of_week(date) in [6, 7] do
      DateCalculator.previous_day_of_week(date, 5)
    else
      date
    end
  end

  def mothers_day(year, _) do
    DateCalculator.nth_day_of_week(year, 5, 1, 7)
  end

  def fathers_day(year, _) do
    DateCalculator.nth_day_of_week(year, 6, 1, 7)
  end

  @doc false
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

  @doc false
  def march_pub_hol_sa(year, _) do
    if year >= 2006, do: DateCalculator.nth_day_of_week(year, 3, 2, 1)
  end

  @doc false
  def qld_labour_day_may(year, _) do
    if year not in 2013..2015, do: DateCalculator.nth_day_of_week(year, 5, 1, 1)
  end

  @doc false
  def may_pub_hol_sa(year, _) do
    if year < 2006, do: DateCalculator.nth_day_of_week(year, 5, 3, 1)
  end

  @doc false
  def qld_queens_birthday_june(2012, _) do
    [DateCalculator.nth_day_of_week(2012, 6, 2, 1), ~D[2012-10-01]]
  end

  def qld_queens_birthday_june(year, _) when year <= 2015 do
    DateCalculator.nth_day_of_week(year, 6, 2, 1)
  end

  def qld_queens_birthday_june(_, _) do
    nil
  end

  @doc false
  def afl_grand_final(year, _) do
    dates = %{
      2015 => ~D[2015-10-02],
      2016 => ~D[2016-09-30],
      2017 => ~D[2017-09-29]
    }

    dates[year]
  end

  @doc false
  def qld_labour_day_october(year, _) do
    if year in 2013..2015, do: DateCalculator.nth_day_of_week(year, 10, 1, 1)
  end

  @doc false
  def qld_queens_bday_october(year, _) do
    if year >= 2016, do: DateCalculator.nth_day_of_week(year, 10, 1, 1)
  end

  @doc false
  def hobart_show_day(year, _) do
    fourth_sat_in_oct = DateCalculator.nth_day_of_week(year, 10, 4, 6)
    Date.add(fourth_sat_in_oct, -2)
  end

  @doc false
  def g20_day_2014_only(2014, _), do: ~D[2014-11-14]
  def g20_day_2014_only(_, _), do: nil

  @doc false
  def to_weekday_if_boxing_weekend(%Date{} = date, _) do
    case Date.day_of_week(date) do
      day when day in 6..7 -> Date.add(date, 2)
      1 -> Date.add(date, 1)
      _ -> date
    end
  end

  @doc false
  def to_weekday_if_boxing_weekend_from_year(year, _) do
    {:ok, boxing} = Date.new(year, 12, 26)

    if Date.day_of_week(boxing) in 6..7 do
      Date.add(boxing, 2)
    else
      boxing
    end
  end

  @doc false
  def to_weekday_if_boxing_weekend_from_year_or_to_tuesday_if_monday(year, _) do
    {:ok, boxing} = Date.new(year, 12, 26)

    case Date.day_of_week(boxing) do
      wday when wday in 6..7 -> Date.add(boxing, 2)
      1 -> Date.add(boxing, 1)
      _ -> boxing
    end
  end

  @doc false
  def ca_victoria_day(year, _) do
    {:ok, date} = Date.new(year, 5, 24)
    DateCalculator.previous_day_of_week(date, 1)
  end

  @doc false
  def ch_vd_lundi_du_jeune_federal(year, _) do
    year
    |> DateCalculator.nth_day_of_week(9, 3, 7)
    |> DateCalculator.next_day_of_week(1)
  end

  @doc false
  def ch_ge_jeune_genevois(year, _) do
    year
    |> DateCalculator.nth_day_of_week(9, 1, 7)
    |> DateCalculator.next_day_of_week(4)
  end

  @doc false
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

  @doc false
  def de_buss_und_bettag(year, _) do
    {:ok, date} = Date.new(year, 11, 23)

    if Date.day_of_week(date) == 3 do
      Date.add(date, -7)
    else
      DateCalculator.previous_day_of_week(date, 3)
    end
  end

  @doc false
  def fi_pyhainpaiva(year, _) do
    {:ok, date} = Date.new(year, 10, 31)
    DateCalculator.next_day_of_week(date, 6)
  end

  @doc false
  def fi_juhannusaatto(year, _) do
    {:ok, date} = Date.new(year, 6, 19)
    DateCalculator.next_day_of_week(date, 5)
  end

  @doc false
  def fi_juhannuspaiva(year, _) do
    {:ok, date} = Date.new(year, 6, 20)
    DateCalculator.next_day_of_week(date, 6)
  end

  @doc false
  def ph_heroes_day(year, _) do
    DateCalculator.nth_day_of_week(year, 8, -1, 1)
  end

  @doc false
  def pl_trzech_kroli_informal(year, _) do
    if year < 2011 do
      {:ok, date} = Date.new(year, 1, 6)
      date
    else
      nil
    end
  end

  @doc false
  def pl_trzech_kroli(year, _) do
    if year >= 2011 do
      {:ok, date} = Date.new(year, 1, 6)
      date
    else
      nil
    end
  end

  @doc false
  def se_midsommardagen(year, _) do
    {:ok, date} = Date.new(year, 6, 20)
    DateCalculator.next_day_of_week(date, 6)
  end

  @doc false
  def se_alla_helgons_dag(year, _) do
    {:ok, date} = Date.new(year, 10, 31)
    DateCalculator.next_day_of_week(date, 6)
  end

  @doc false
  def epiphany(year, _) do
    {:ok, date} = Date.new(year, 1, 6)
    day_of_week = Date.day_of_week(date)

    cond do
      day_of_week > 1 && day_of_week < 7 ->
        Date.add(date, 8 - day_of_week)

      day_of_week == 7 ->
        Date.add(date, 1)

      true ->
        date
    end
  end

  @doc false
  def to_nearest_monday_after(year, rule) do
    {:ok, date} = Date.new(year, rule.month, rule.day)
    DateCalculator.to_nearest_monday_after(date)
  end

  @doc false
  def qld_brisbane_ekka_holiday(year, rule) do
    first_friday = DateCalculator.nth_day_of_week(year, rule.month, 1, 5)

    date =
      if first_friday.day < 5 do
        DateCalculator.nth_day_of_week(year, rule.month, 2, 5)
      else
        first_friday
      end

    Date.add(date, 5)
  end

  @doc false
  def qld_kings_bday_october(year, rule) do
    if year >= 2023 do
      DateCalculator.nth_day_of_week(year, rule.month, 1, 1)
    end
  end

  @doc false
  def ch_be_zibelemaerit(year, rule) do
    DateCalculator.nth_day_of_week(year, rule.month, 4, 1)
  end

  @doc false
  def saint_josephs_day(year, rule), do: co_shift_date(year, rule, 19)
  @doc false
  def saint_peter_and_saint_paul(year, rule), do: co_shift_date(year, rule, 29)
  @doc false
  def assumption_of_mary(year, rule), do: co_shift_date(year, rule, 15)
  @doc false
  def columbus_day(year, rule), do: co_shift_date(year, rule, 12)
  @doc false
  def all_saints_day(year, rule), do: co_shift_date(year, rule, 1)
  @doc false
  def independence_of_cartagena(year, rule), do: co_shift_date(year, rule, 11)

  defp co_shift_date(year, rule, day) do
    {:ok, date} = Date.new(year, rule.month, day)
    day_of_week = Date.day_of_week(date)

    if day_of_week > 1 do
      Date.add(date, 8 - day_of_week)
    else
      date
    end
  end
end
