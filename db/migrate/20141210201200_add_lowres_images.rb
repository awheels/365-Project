class AddLowresImages < ActiveRecord::Migration
  def change
    add_column :images, :lowres, :string
  end
end