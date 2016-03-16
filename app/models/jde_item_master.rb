class JdeItemMaster < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4101" #im

  def self.get_item_number(short_item)
    where(imitm: short_item)
  end
end
