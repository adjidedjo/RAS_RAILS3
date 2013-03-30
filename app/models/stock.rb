class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
  scope :check_stock, lambda {|date| where(:tanggal => date)}
  scope :find_kodebrg, lambda {|kodebrg| where(:kodebrg => kodebrg)}
  scope :find_cabang_id, lambda {|cabang_id| where(:cabang_id => cabang_id)}
  
  validates :date, :presence => true

	def self.get_record(date)
		find(:all, :select => "cabang_id, kodebrg, namabrg, freestock, bufferstock",:conditions => ["tanggal = ?", date], :group => :kodebrg, :order => "id DESC")
	end
  
  def self.get_stock_in_branch(date, stock)
    check_stock(date).find_kodebrg(stock)
  end
end

