class CreateStoreMaps < ActiveRecord::Migration
  def change
    create_table :store_maps do |t|
      t.text :address
      t.string :city
      t.float :latitude
      t.float :longitude
      t.boolean :gmaps

      t.timestamps
    end
  end
end
