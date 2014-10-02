module SalesReportsHelper
    
  def options_for_tipe_pengecekan
    ["Harga", "Upgrade"]
  end
  
  def options_for_tipe
    ["Non Serenity", "Serenity", "Lady Americana", "Royal", "Classic", "Grand", "Display",
      "Clearance Sale", "Return"
    ]
  end
  
  def faktur(brand)
    if brand == 'Non Serenity'
      "FKE"
    elsif brand == 'Serenity'
      "FKS"
    elsif brand == 'Lady Americana'
      "FKL"
    elsif brand == 'Royal'
      "FKR"
    elsif brand == 'Classic'
      "FKC"
    elsif brand == 'Clearance Sale'
      "FKD"
    elsif brand == 'Display'
      "FKY"
    else
      "RTR"
    end
  end
  
  def brand(brand)
    if brand == 'Non Serenity'
      "E"
    elsif brand == 'Serenity'
      "S"
    elsif brand == 'Lady Americana'
      "L"
    elsif brand == 'Royal'
      "R"
    elsif brand == 'Classic'
      "C"
    elsif brand == 'Clearance Sale'
      "D"
    elsif brand == 'Display'
      "Y"
    else
      "R"
    end
  end
  
  def view_nofaktur(brand, branch, date, nofaktur)
    faktur(brand)+"-"+"0"+branch+"-"+Date.today.to_date.year.to_s[2,2]+"0"+date+"-"+nofaktur.to_s.rjust(5,'0')
  end
end