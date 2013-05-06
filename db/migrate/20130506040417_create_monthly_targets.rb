class CreateMonthlyTargets < ActiveRecord::Migration
  def change
    create_table :monthly_targets do |t|
      t.integer :cabang_id
      t.string :target_year
      t.string :target_month
      t.integer :brand_id

      t.timestamps
    end

    add_index :monthly_targets, [:cabang_id]
    add_index :monthly_targets, [:target_year]
    add_index :monthly_targets, [:brand_id]
    add_index :monthly_targets, [:target_month]
  end
end
