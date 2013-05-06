class YearlyTarget < ActiveRecord::Base
	belongs_to :cabang

	def self.get_yearly_target(brand, cabang, date)
		find(:all, :select => "total", :conditions => ["brand_id = ? and cabang_id = ? and year(target_year) = ?", brand, cabang, date.year])
	end
end
