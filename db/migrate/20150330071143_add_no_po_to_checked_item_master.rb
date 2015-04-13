class AddNoPoToCheckedItemMaster < ActiveRecord::Migration
  def change
    add_column :checked_item_masters, :no_po, :string
  end
end
