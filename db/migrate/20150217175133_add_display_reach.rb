class AddDisplayReach < ActiveRecord::Migration
  def change
    add_column :noises, :display_reach, :integer
  end
end
