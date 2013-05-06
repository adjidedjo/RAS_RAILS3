class AddTotalToMonthlyTargets < ActiveRecord::Migration
  def change
    add_column :monthly_targets, :total, :decimal
  end
end
