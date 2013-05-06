class MonthlyTarget < ActiveRecord::Base
	belongs_to :cabang

	def self.get_monthly_target(brand, cabang, date)
		find(:all, :select => "total", :conditions => ["brand_id = ? and cabang_id = ? and target_month = ?", brand, cabang, date])
	end

end
