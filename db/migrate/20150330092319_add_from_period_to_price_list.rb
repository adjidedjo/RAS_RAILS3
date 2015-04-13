class AddFromPeriodToPriceList < ActiveRecord::Migration
  def change
    add_column :price_lists, :from_period, :date
    add_column :price_lists, :to_period, :date
  end
end
