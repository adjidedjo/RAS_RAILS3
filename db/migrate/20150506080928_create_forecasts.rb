class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      t.integer :cabang_id
      t.integer :bulan
      t.integer :tahun
      t.string :kode_forecast
      t.string :artikel
      t.string :kain
      t.integer :jumlah

      t.timestamps
    end
  end
end
