class TmpBrand < ActiveRecord::Base
  scope :not_equal_with_nosj, where("nosj not like ? and nosj not like ? and nosj not like ? and nosj not like ? and ketppb not like ?", %(#{'SJB'}%), %(#{'SJY'}%), %(#{'SJV'}%), %(#{'SJP'}%), %(#{'RD'}%))
	scope :search_by_month_and_year, lambda { |month, year| where("bulan = ? and tahun = ?", month, year)}
	scope :search_by_branch, lambda {|branch| where("cabang_id in (?)", branch) if branch.present? }
  scope :brand, lambda {|brand| where("brand in (?)", brand) if brand.present?}
	
  def self.customer_quick_monthly(month, year, branch, brand)
    select("sum(qty) as qty, sum(val) as val")
    .search_by_month_and_year(month, year).search_by_branch(branch).brand(brand)
	end
end