class SalesReport < ActiveRecord::Base
  set_table_name "warehouse.tblaporancabang"
  attr_accessible *column_names
  
  scope :search_by_month_and_year, lambda { |month, year| where("MONTH(tanggalsj) = ? and YEAR(tanggalsj) = ?", month, year)}
	scope :not_equal_with_nofaktur, where("nofaktur not like ? and nofaktur not like ? and nofaktur not like ? and nofaktur not like ? and nofaktur not like ?", %(#{'FKD'}%), %(#{'FKB'}%), %(#{'FKY'}%), %(#{'FKV'}%), %(#{'FKP'}%))
	scope :no_return, where("nofaktur not like ? and nofaktur not like ? ", %(#{'RTR'}%),%(#{'RET'}%))
	scope :brand, lambda {|brand| where("nofaktur like ?", %(%#{brand}%)) if brand.present?}
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  
end
