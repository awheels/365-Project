class AddDateToImages < ActiveRecord::Migration
  def change
    add_column :images, :date, :string
  end
end