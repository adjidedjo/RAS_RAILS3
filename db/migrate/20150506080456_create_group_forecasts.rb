class CreateGroupForecasts < ActiveRecord::Migration
  def change
    create_table :group_forecasts do |t|
      t.string :kode_barang
      t.string :kode_forecast

      t.timestamps
    end
  end
end
