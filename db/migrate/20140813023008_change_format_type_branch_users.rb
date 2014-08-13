class ChangeFormatTypeBranchUsers < ActiveRecord::Migration
  def change
    change_column :users, :branch, :integer
  end
end
