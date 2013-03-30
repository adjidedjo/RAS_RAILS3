class Stock < ActiveRecord::Base
  set_table_name "tbstockcabang"
  belongs_to :cabang
  belongs_to :barang
  scope :find_cabang_id, lambda {|cabang_id| where(:cabang_id => cabang_id)}

	def self.get_record(date, current_user)
    if current_user.merk.nil?
      find(:all, :select => "cabang_id, kodebrg, namabrg, freestock, bufferstock",
        :conditions => ["tanggal = ?", date], :order => "id DESC")
    else
      find(:all, :select => "cabang_id, kodebrg, namabrg, freestock, bufferstock",
        :conditions => ["tanggal = ? and kodebrg like ?", date, "%#{current_user.merk.merk_id}%"],
        :order => "id DESC")
    end
	end
  
  def self.get_stock_in_branch(date, stock)
    find(:all, :select => "tanggal, cabang_id, kodebrg, freestock, bufferstock",
      :conditions => ["tanggal = ? and kodebrg like ?", date, stock])
  end
end