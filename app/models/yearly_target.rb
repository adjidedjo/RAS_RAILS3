class YearlyTarget < ActiveRecord::Base
	belongs_to :cabang

	validates :target_year, :total, :presence => true
	validates :total, :numericality => true
	validates_uniqueness_of :target_year, :cabang_id, :brand_id, :scope => [:target_year, :cabang_id, :brand_id], :message => "should happen once per year"

	def self.get_yearly_target(brand, cabang, date)
		select("total").where("brand_id = ? and cabang_id = ? and target_year = ?", brand, cabang, date.year)
	end
end
