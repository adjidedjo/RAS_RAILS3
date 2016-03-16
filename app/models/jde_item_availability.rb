class JdeItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f41021" #sd


  def self.available
    where("limcu like ? and lipqoh >= ?", "%11011", 1)
  end
end
