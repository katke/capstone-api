class CreatePerishables < ActiveRecord::Migration
  def change
    create_table :perishables do |t|
      t.integer :noise_id
      t.date :start
      t.date :end

      t.timestamps
    end
  end
end
