class Place < ActiveRecord::Base
    belongs_to :user
	has_many :pictures, :dependent => :destroy 
	
	accepts_nested_attributes_for :pictures, :allow_destroy => true
	
	validates_presence_of :price, :rooms, :bathrooms, :description, :for, :address, message: "All fields are required, but pictures aren't." 
	validates_length_of :pictures, maximum: 3, message: "3 or less pictures, please!"
	
	self.per_page = 10
	
    def self.search(query)
        if query
            where("address LIKE :query or description LIKE :query", {query: "%#{query}%"})
        else
            all
        end
    end
end
