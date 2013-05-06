class AddNameToStoreMaps < ActiveRecord::Migration
  def change
    add_column :store_maps, :name, :string
  end
end
