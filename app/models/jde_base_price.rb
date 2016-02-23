class JdeBasePrice < ActiveRecord::Base
  establish_connection "jdeoracle"
  self.table_name = "proddta.f4106"
  #bp

  def self.harga_satuan(item, branch_plant, order_date)
    harga = where("bpitm = ? and bpmcu like ? and bpexdj >= ?", item, "%#{branch_plant}", order_date)
    if harga.nil? || harga.empty?
      0
    else
      harga.first.bpuprc
    end
  end
end
