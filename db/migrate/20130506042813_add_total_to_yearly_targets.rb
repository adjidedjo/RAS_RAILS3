class AddTotalToYearlyTargets < ActiveRecord::Migration
  def change
    add_column :yearly_targets, :total, :decimal
  end
end
