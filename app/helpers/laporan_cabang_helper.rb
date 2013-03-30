module LaporanCabangHelper
  # year and month
  def get_last_month_on_last_year_helper(date)
    1.year.ago(date.to_date.beginning_of_month).to_date
  end

  def get_last_month_on_current_year_helper(date)
    date.to_date.beginning_of_month.to_date
  end

  def get_beginning_of_year_on_last_year_helper(date)
    1.year.ago(date.to_date.beginning_of_year).to_date
  end

  def get_beginning_of_year_on_current_year_helper(date)
    date.to_date.beginning_of_year.to_date
  end

  # week
  def last_week_on_last_year(date)
    1.year.ago(1.weeks.ago(date.to_date - 6.days)).to_date
  end

  def week_on_last_year(date)
    1.year.ago(date.to_date).to_date
  end

  def last_week_on_current_year(date)
    1.weeks.ago(date.to_date - 6.days).to_date
  end

  def week_on_current_year(date)
    (date - 6.days).to_date
  end

  def get_percentage(last_month, current_month)
    (current_month.to_f - last_month.to_f) / last_month.to_f * 100.0
  end
end
