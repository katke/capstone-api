class CreateNoises < ActiveRecord::Migration
  def change
    create_table :noises do |t|
      t.text :description
      t.string :noise_type
      t.float :lat
      t.float :lon
      t.integer :decibel
      t.integer :reach

      t.timestamps
    end
  end
end
