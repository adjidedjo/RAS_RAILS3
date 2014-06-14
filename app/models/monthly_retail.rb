class MonthlyRetail < ActiveRecord::Base
	validates_uniqueness_of :customer,:cabang_id, :brand_id, :scope => [:customer, :cabang_id, :brand_id], 
    :message => "should happen once per year"
end
