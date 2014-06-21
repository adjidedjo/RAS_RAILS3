module ApplicationHelper
  
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
end
