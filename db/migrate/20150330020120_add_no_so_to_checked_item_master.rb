class AddNoSoToCheckedItemMaster < ActiveRecord::Migration
  def change
    add_column :checked_item_masters, :no_so, :string
  end
end
