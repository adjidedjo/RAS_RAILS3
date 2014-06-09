class MonthlyTarget < ActiveRecord::Base
  belongs_to :cabang
  belongs_to :salesman
  belongs_to :merk

	 validates_uniqueness_of :target_year, :cabang_id, :merk_id, :sales_id, :customer, :scope => [:target_year, :cabang_id, :merk_id, :sales, :customer], 
		:message => "should happen once per year"

  scope :branch, lambda {|branch| where(:cabang_id => branch) unless branch.nil?}
  scope :merk, lambda {|merk| where(:merk_id => merk) unless merk.nil?}
  scope :bm, lambda {|bm| where(:bm => bm) if bm.present?}
  scope :asm, lambda {|asm| where(:asm => asm) if asm.present}
  scope :sales, lambda {|sales| where(:sales => sales) if sales.present?}
  scope :sales_counter, lambda {|sales_counter| where(:sales_counter => sales_counter) if sales_counter.present?}
  scope :date, lambda {|date| where(:target_year => date.year) if date.present?}

	 def self.get_monthly_target(merk, cabang, month, year)
		 find(:all, :select => "total", :conditions => ["merk_id = ? and cabang_id = ? and target_year = ?", 
			 merk, cabang, %(#{year +'-01-'+'01'})])
	 end

  def self.get_target(cabang, merk, date)
    select("cabang_id").branch(cabang).merk(merk)
  end
end
