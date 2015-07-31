class AddKeteranganToPriceLists < ActiveRecord::Migration
  def change
    add_column :price_lists, :keterangan, :string
    add_column :price_lists, :status, :string
  end
end
