module ApplicationHelper
  
  def options_for_bulan
    [[Date::MONTHNAMES[1], 1],[Date::MONTHNAMES[2], 2],[Date::MONTHNAMES[3], 3],
      [Date::MONTHNAMES[4], 4],[Date::MONTHNAMES[5], 5],[Date::MONTHNAMES[6], 6],
      [Date::MONTHNAMES[7], 7],[Date::MONTHNAMES[8], 8],[Date::MONTHNAMES[9], 9],
      [Date::MONTHNAMES[10], 10],[Date::MONTHNAMES[11], 11],[Date::MONTHNAMES[12], 12]]
  end
  
  def currency(price)
    number_to_currency(price, :precision => 0, :unit => "", :delimiter => ".")
  end
  
  def percentage(price)
    number_to_percentage(price, :precision => 0)
  end
  
  def jenis(jenis)
    if jenis == "KM"
      "Kasur Matras"
    elsif jenis == "DV"
      "Divan"
    elsif jenis == "HB"
      "Sandaran"
    elsif jenis == "KB"
      "Kasur Busa"
    elsif jenis == "SA"
      "Sorong Atas"
    else
      "Sorong Bawah"
    end
  end
  
  def chart_nonser
    Cabang.get_id.map do |merk|
      {
        merk: merk.Alias,
        quantity_nonser: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, Date.today.beginning_of_month, Date.today, 'Non Serenity').sum(:qty_month),
        quantity_last_nonser: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, (Date.today.ago(1.month).beginning_of_month.to_date), (Date.today.ago(1.month).to_date), 'Non Serenity').sum(:qty_month)
      }
    end
  end
  
  def chart_lady
    Cabang.get_id.map do |merk|
      {
        merk: merk.Alias,
        quantity_lady: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, Date.today.beginning_of_month, Date.today, 'Lady Americana').sum(:qty_month),
        quantity_last_lady: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, (Date.today.ago(1.month).beginning_of_month.to_date), (Date.today.ago(1.month).to_date), 'Lady Americana').sum(:qty_month)
      }
    end
  end
  
  def chart_serenity
    Cabang.get_id.map do |merk|
      {
        merk: merk.Alias,
        quantity_ser: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, Date.today.beginning_of_month, Date.today, 'Serenity').sum(:qty_month),
        quantity_last_ser: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, (Date.today.ago(1.month).beginning_of_month.to_date), (Date.today.ago(1.month).to_date), 'Serenity').sum(:qty_month)
      }
    end
  end
  
  def chart_royal
    Cabang.get_id.map do |merk|
      {
        merk: merk.Alias,
        quantity_royal: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, Date.today.beginning_of_month, Date.today, 'Royal').sum(:qty_month),
        quantity_last_royal: ComparisonBetweenMonth.where("branch = ? and first_day = ? and latest_day = ? and brand like ?", merk, (Date.today.ago(1.month).beginning_of_month.to_date), (Date.today.ago(1.month).to_date), 'Royal').sum(:qty_month)
      }
    end
  end
end