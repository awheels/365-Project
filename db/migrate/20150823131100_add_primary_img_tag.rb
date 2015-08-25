class AddPrimaryImgTag < ActiveRecord::Migration
  def change
    add_column :images, :tag, :boolean, :default => false
  end
end