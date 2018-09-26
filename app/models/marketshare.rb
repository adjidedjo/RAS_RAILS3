class Marketshare < ActiveRecord::Base
  has_many :marketshare_brands, dependent: :destroy
  accepts_nested_attributes_for :marketshare_brands, reject_if: :all_blank, allow_destroy: true
  
  def self.auto_create_next_month
    marketshare = where("start_date = '#{1.month.ago.strftime("%m/%Y")}' AND end_date = '#{1.month.ago.strftime("%m/%Y")}'")
    marketshare.each do |mb|
      new_month = self.create!(customer_id: mb.customer_id, area_id: mb.area_id, city: mb.city, 
      start_date: Date.today.strftime("%m/%Y"), end_date: Date.today.strftime("%m/%Y"), brand: mb.brand)
      mb.marketshare_brands.each do |mbs|
        MarketshareBrand.create!(marketshare_id: new_month.id, amount: mbs.amount, name: mbs.name, city: mbs.city,
        start_date: new_month.start_date, end_date: new_month.end_date, customer_name: mbs.customer_name, area_id: mbs.area_id,
        internal_brand: mbs.internal_brand)
      end
    end
  end

end
