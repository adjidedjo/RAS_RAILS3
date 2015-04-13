class AddImageFilenameToPriceLists < ActiveRecord::Migration
  def change
    add_column :price_lists, :image_filename, :string
  end
end
