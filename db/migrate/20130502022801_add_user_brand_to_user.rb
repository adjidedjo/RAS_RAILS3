class AddUserBrandToUser < ActiveRecord::Migration
  def change
  	add_column :users, :user_brand, :string
  end
end
