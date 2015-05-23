class AddActiveToPriceLists < ActiveRecord::Migration
  def change
    add_column :price_lists, :active, :boolean, :default => 0
  end
end
