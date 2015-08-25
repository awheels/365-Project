class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :accesstoken
      t.string :instagram_id
      t.timestamps
    end
  end
end
