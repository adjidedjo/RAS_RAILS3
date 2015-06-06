class MonthlyTarget < ActiveRecord::Base
  belongs_to :cabang
  belongs_to :salesman
  belongs_to :merk

  validates_uniqueness_of :target_year, :cabang_id, :merk_id, :customer, :scope => [:target_year, :cabang_id, :merk_id, :sales, :customer],
		:message => "should happen once per year"

  scope :branch, lambda {|branch| where(:cabang_id => branch) if branch.present?}
  scope :merk, lambda {|merk| where(:merk_id => merk) if merk.present?}
  scope :bm, lambda {|bm| where(:bm => bm) if bm.present?}
  scope :asm, lambda {|asm| where(:asm => asm) if asm.present}
  scope :sales, lambda {|sales| where(:sales => sales) if sales.present?}
  scope :sales_counter, lambda {|sales_counter| where(:sales_counter => sales_counter) if sales_counter.present?}
  scope :date, lambda {|date| where(:target_year => date.year) if date.present?}

  def self.sum_of_month_year
    
  end

  def self.get_monthly_target(merk, cabang, month, year)
    find(:all, :select => "total", :conditions => ["merk_id = ? and cabang_id = ? and target_year = ?",
        merk, cabang, %(#{year +'-01-'+'01'})])
  end

  def self.get_target_by_branch(cabang, merk, date)
    month_selected = date.to_date.strftime("%B").downcase if date.present?
    select("cabang_id, #{month_selected}").branch(cabang).merk(merk).date(date.to_date).group("cabang_id").sum("#{month_selected}")
  end

  def self.get_target_by_year(cabang, merk, date)
    month_selected = date.to_date.strftime("%B").downcase if date.present?
    self.branch(cabang).merk(merk).date(date.to_date).group(:cabang_id, :january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december)
  end

  def self.get_target_by_sales(cabang, merk, date)
    month_selected = date.to_date.strftime("%B").downcase
    select("cabang_id, sales, #{month_selected}, merk_id").branch(cabang).merk(merk).date(date.to_date)
  end
end