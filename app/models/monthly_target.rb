class MonthlyTarget < ActiveRecord::Base
	has_many :months
  accepts_nested_attributes_for :months, :allow_destroy => true
	belongs_to :cabang

	validates_uniqueness_of :target_year,:cabang_id, :brand_id, :scope => [:target_year, :cabang_id, :brand_id], 
		:message => "should happen once per year"

	def self.get_monthly_target(brand, cabang, month, year)
		find(:all, :select => "total", :conditions => ["brand_id = ? and cabang_id = ? and target_year = ?", 
			brand, cabang, %(#{year +'-01-'+'01'})])
	end
end
