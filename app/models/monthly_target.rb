class MonthlyTarget < ActiveRecord::Base
	belongs_to :cabang

	validates :target_year, :total, :presence => true
	validates :total, :numericality => true
	validates_uniqueness_of :target_year, :target_month,:cabang_id, :brand_id, :scope => [:target_year, :target_month, :cabang_id, :brand_id], 
		:message => "should happen once per year"

	def self.get_monthly_target(brand, cabang, month, year)
		find(:all, :select => "total", :conditions => ["brand_id = ? and cabang_id = ? and target_month = ? and target_year = ?", 
			brand, cabang, %(#{'0001-'+ month +'-01'}), %(#{year +'-01-'+'01'})])
	end
end
