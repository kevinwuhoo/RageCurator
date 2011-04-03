class AddQueueColumn < ActiveRecord::Migration
  def self.up
    add_column :comics, :queue, :boolean
  end

  def self.down
    remove_column :comics, :queue
  end
end
