class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
	scope :check_stock, lambda {|date| where(:tanggal => date)}
	scope :check_branch, lambda {|cabang| where(:cabang_id => cabang)}

	def self.find_barang_id(barang_id, cabang)
		find(:all, :select => "tanggal, cabang_id, kodebrg, freestock, bufferstock, realstock",
			:conditions => ["kodebrg = ? and cabang_id = ?", barang_id, cabang])
	end

  def self.get_stock_in_branch(date, stock, cabang)
    check_stock(date).find_barang_id(stock, cabang)
  end

  def self.get_size_qty(kodebrg, cabang, date, size)
  	find(:all, :select => "kodebrg, freestock, bufferstock, realstock",
  		:conditions => ["kodebrg like ? and kodebrg not like ? and cabang_id = ? and tanggal = ?", %(#{kodebrg + size}%), %(%#{'T'}%),
  		cabang, date])
  end
end
