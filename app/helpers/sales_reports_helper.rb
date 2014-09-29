module SalesReportsHelper
  def faktur(brand)
    if brand == 'Non Serenity'
      "FKE"
    elsif brand == 'Serenity'
      "FKS"
    elsif brand == 'Lady Americana'
      "FKL"
    elsif brand == 'Royal'
      "FKR"
    else
      "FKC"
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
    else
      "C"
    end
  end
  
  def view_nofaktur(brand, branch, date, nofaktur)
    faktur(brand)+"-"+"0"+branch+"-"+Date.today.to_date.year.to_s[2,2]+"0"+date+"-"+nofaktur.to_s.rjust(5,'0')
  end
end