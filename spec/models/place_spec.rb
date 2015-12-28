require 'rails_helper'

RSpec.describe Place, type: :model do
    place = Place.create!(description: "Test description", address: "232 Street Name, Random City", latitude: -10.0012, longitude: -12.2414, rooms: 2, bathrooms: 3, for: "sale", price: 12344)
    
    it "should show correctly" do 
        expect(place.description).to eq("Test description")
        expect(place.address).to eq("232 Street Name, Random City")
    end
    
    it "latitude and longitude should be floats" do 
        expect(place.latitude.class).to eq(Float)
        expect(place.longitude.class).to eq(Float)
    end 
    
    it "rooms and bathrooms should be Fixnums" do 
        expect(place.rooms.class).to eq(Fixnum)
        expect(place.bathrooms.class).to eq(Fixnum)
    end 
    
    it "rooms, bathrooms and price cannot be below zero" do 
        expect(place.rooms).to_not be < 0
        expect(place.bathrooms).to_not be < 0
        expect(place.price).to_not be < 0
    end 
end
