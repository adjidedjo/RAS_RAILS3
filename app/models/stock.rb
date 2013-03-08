class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
  scope :check_stock, lambda {|date| where(:tanggal => date)}
  scope :find_barang_id, lambda {|barang_id| where(:barang_id => barang_id)}
  scope :find_cabang_id, lambda {|cabang_id| where(:cabang_id => cabang_id)}
  
  validates :date, :presence => true
  
  def self.get_stock_in_branch(date, stock)
    check_stock(date).find_barang_id(stock)
  end
  
  def self.get_stock_by_category(category)
    category.map do |cat|
      where(['kodebrg like ?', "%#{cat}%"])
    end.flatten
    
  end
end