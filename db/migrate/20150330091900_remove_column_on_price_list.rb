class RemoveColumnOnPriceList < ActiveRecord::Migration
  def up
    remove_column :price_lists, :prev_harga
    remove_column :price_lists, :prev_discount_1
    remove_column :price_lists, :prev_discount_2
    remove_column :price_lists, :prev_discount_3
    remove_column :price_lists, :prev_discount_4
    remove_column :price_lists, :prev_upgrade
    remove_column :price_lists, :prev_special_price
  end

  def down
    add_column :price_lists, :prev_harga
    add_column :price_lists, :prev_discount_1
    add_column :price_lists, :prev_discount_2
    add_column :price_lists, :prev_discount_3
    add_column :price_lists, :prev_discount_4
    add_column :price_lists, :prev_upgrade
    add_column :price_lists, :prev_special_price
  end
end
