class ChangeImageToLink < ActiveRecord::Migration
  def self.up
    rename_column :comics, :image, :link
  end

  def self.down
    rename_column :comics, :link, :image
  end
end
