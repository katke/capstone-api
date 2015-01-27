class AddSeasonalColumn < ActiveRecord::Migration
  def change
    add_column :noises, :seasonal, :boolean
  end
end
