class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :places do |t|
      t.float :lat
      t.float :lng
      t.string :address
      t.boolean :available
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
