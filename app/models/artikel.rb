class Artikel < ActiveRecord::Base
  set_table_name "tbbjkodeartikel"
  has_many :artikel
  scope :artikel_name, lambda {|artikel| where(:KodeCollection => artikel)}
  
  def self.get_artikel_name(artikel_id)
    artikel_name(artikel_id).map{|artikel| artikel.Produk}.join(",")
  end
end
