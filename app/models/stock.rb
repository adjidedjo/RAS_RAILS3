class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
	scope :check_stock, lambda {|date| where(:tanggal => date)}

	def self.find_barang_id(barang_id)
		find(:all, :select => "tanggal, cabang_id, kodebrg, freestock, bufferstock",
			:conditions => ["kodebrg =?", barang_id])
	end

  def self.get_stock_in_branch(date, stock)
    check_stock(date).find_barang_id(stock)
  end
end
