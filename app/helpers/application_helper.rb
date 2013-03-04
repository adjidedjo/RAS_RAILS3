module ApplicationHelper
  
  def currency(price)
    number_to_currency(price, :precision => 0, :unit => "", :delimiter => ".")
  end
  
  def percentage(price)
    number_to_percentage(price, :precision => 0)
  end
end
