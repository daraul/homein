class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string  :description
      t.string  :address
      t.float   :latitude
      t.float   :longitude
      t.integer :rooms
      t.integer :bathrooms
      t.string  :for 
      t.integer :price
      t.belongs_to :user, index: true 

      t.timestamps null: false
    end
  end
end
