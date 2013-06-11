class CreateUsersMails < ActiveRecord::Migration
  def change
    create_table :users_mails do |t|
      t.integer :user_id
      t.datetime :from
      t.datetime :to
      t.string :brand
      t.string :type
      t.integer :cabang_id

      t.timestamps
    end
  end
end
