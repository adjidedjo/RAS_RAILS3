class AddImageToPriceLists < ActiveRecord::Migration
  def change
    add_column :price_lists, :image, :string
  end
end
