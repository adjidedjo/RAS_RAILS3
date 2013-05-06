class CreateYearlyTargets < ActiveRecord::Migration
  def change
    create_table :yearly_targets do |t|
      t.integer :cabang_id
      t.string :target_year
      t.integer :brand_id

      t.timestamps
    end
    add_index :yearly_targets, [:cabang_id]
    add_index :yearly_targets, [:target_year]
    add_index :yearly_targets, [:brand_id]
  end
end
