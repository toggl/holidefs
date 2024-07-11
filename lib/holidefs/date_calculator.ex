defmodule Holidefs.DateCalculator do
  @moduledoc """
  Some functions to calculate dynamic holiday dates.
  """

  @doc """
  Returns the date of Easter for the given `year`.

  ## Examples

      iex> Holidefs.DateCalculator.gregorian_easter(2016)
      ~D[2016-03-27]

      iex> Holidefs.DateCalculator.gregorian_easter(2015)
      ~D[2015-04-05]

  """
  @spec gregorian_easter(integer) :: Date.t()
  def gregorian_easter(year) do
    y = year
    a = rem(y, 19)
    b = div(y, 100)
    c = rem(y, 100)
    d = div(b, 4)
    e = rem(b, 4)
    f = div(b + 8, 25)
    g = div(b - f + 1, 3)
    h = rem(19 * a + b - d - g + 15, 30)
    i = div(c, 4)
    k = rem(c, 4)
    l = rem(32 + 2 * e + 2 * i - h - k, 7)
    m = div(a + 11 * h + 22 * l, 451)

    month = div(h + l - 7 * m + 114, 31)
    day = rem(h + l - 7 * m + 114, 31) + 1

    {:ok, date} = Date.new(year, month, day)
    date
  end

  @doc """
  Returns the date of Orthodox Easter for the given `year`.

  ## Examples

      iex> Holidefs.DateCalculator.gregorian_orthodox_easter(2016)
      ~D[2016-05-01]

      iex> Holidefs.DateCalculator.gregorian_orthodox_easter(2015)
      ~D[2015-04-12]

  """
  @spec gregorian_orthodox_easter(integer) :: Date.t()
  def gregorian_orthodox_easter(year) do
    j_date = julian_orthodox_easter(year)

    offset =
      case year do
        # between the years 1583 and 1699 10 days are added to the julian day count
        _y when year >= 1583 and year <= 1699 ->
          10

        # after 1700, 1 day is added for each century, except if the century year is
        # exactly divisible by 400 (in which case no days are added).
        # Safe until 4100 AD, when one leap day will be removed.
        year when year >= 1700 ->
          div(year - 1600, 100) - div(year - 1600, 400) + 10

        # up until 1582, julian and gregorian easter dates were identical
        _ ->
          0
      end

    Date.add(j_date, offset)
  end

  @doc """
  Returns the date of Orthodox Easter for the given `year`.

  ## Examples

      iex> Holidefs.DateCalculator.julian_orthodox_easter(2016)
      ~D[2016-04-18]

      iex> Holidefs.DateCalculator.julian_orthodox_easter(2015)
      ~D[2015-03-30]

  """
  @spec julian_orthodox_easter(integer) :: Date.t()
  def julian_orthodox_easter(year) do
    y = year
    g = rem(y, 19)
    i = rem(19 * g + 15, 30)
    j = rem(year + div(year, 4) + i, 7)
    j_month = 3 + div(i - j + 40, 44)
    j_day = i - j + 28 - 31 * div(j_month, 4)

    {:ok, date} = Date.new(year, j_month, j_day)
    date
  end

  @doc """
  Returns the nth day of the week.
  """
  @spec nth_day_of_week(integer, integer, integer, integer) :: Date.t()
  def nth_day_of_week(year, month, -1, weekday) do
    year
    |> end_of_month(month)
    |> previous_day_of_week(weekday)
  end

  def nth_day_of_week(year, month, 1, weekday) do
    year
    |> beginning_of_month(month)
    |> next_day_of_week(weekday)
  end

  def nth_day_of_week(year, month, week, weekday) when week < -1 do
    year
    |> nth_day_of_week(month, week + 1, weekday)
    |> Date.add(-7)
  end

  def nth_day_of_week(year, month, week, weekday) when week > 1 do
    year
    |> nth_day_of_week(month, week - 1, weekday)
    |> Date.add(7)
  end

  @doc """
  Returns the next day of week after the given day.
  """
  @spec next_day_of_week(Date.t(), integer) :: Date.t()
  def next_day_of_week(date, day_of_week) do
    diff = day_of_week - Date.day_of_week(date)

    if diff < 0 do
      Date.add(date, diff + 7)
    else
      Date.add(date, diff)
    end
  end

  @doc """
  Returns the previous day of week after the given day.
  """
  @spec previous_day_of_week(Date.t(), integer) :: Date.t()
  def previous_day_of_week(date, day_of_week) do
    diff = day_of_week - Date.day_of_week(date)

    if diff > 0 do
      Date.add(date, diff - 7)
    else
      Date.add(date, diff)
    end
  end

  @doc """
  Returns the first day of the given month on the given year.
  """
  @spec beginning_of_month(integer, integer) :: Date.t()
  def beginning_of_month(year, month) do
    {:ok, first} = Date.new(year, month, 1)
    first
  end

  defp next_beginning_of_month(year, 12), do: beginning_of_month(year + 1, 1)
  defp next_beginning_of_month(year, month), do: beginning_of_month(year, month + 1)

  defp end_of_month(year, month) do
    year
    |> next_beginning_of_month(month)
    |> Date.add(-1)
  end

  def to_nearest_monday_after(date) do
    day =
      case Date.day_of_week(date) do
        1 -> 0
        2 -> 6
        3 -> 5
        4 -> 4
        5 -> 3
        6 -> 2
        7 -> 1
      end

    Date.add(date, day)
  end
end
