class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :branch, :string
  end
end
