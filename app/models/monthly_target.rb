class MonthlyTarget < ActiveRecord::Base
	 has_many :months
  accepts_nested_attributes_for :months, :allow_destroy => true
	 belongs_to :cabang
  belongs_to :saleman
  belongs_to :merk

	 validates_uniqueness_of :target_year, :cabang_id, :merk_id, :sales_id, :customer, :scope => [:target_year, :cabang_id, :merk_id, :sales_id, :customer], 
		:message => "should happen once per year"

	 def self.get_monthly_target(merk, cabang, month, year)
		 find(:all, :select => "total", :conditions => ["merk_id = ? and cabang_id = ? and target_year = ?", 
			 merk, cabang, %(#{year +'-01-'+'01'})])
	 end
end
