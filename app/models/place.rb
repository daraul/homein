class Place < ActiveRecord::Base
    require 'csv'
    
	belongs_to :user
	has_many :pictures, :dependent => :destroy 
	
	accepts_nested_attributes_for :pictures, :allow_destroy => true
	
	validates_presence_of :price, :rooms, :bathrooms, :description, :address, message: "All fields are required, but pictures aren't." 
	validates_length_of :pictures, maximum: 3, message: "3 or less pictures, please!"
	
	include AlgoliaSearch
	
	algoliasearch index_name: "homein_places", per_environment: true do 
	    attributesForFaceting [:rooms, :bathrooms, :price]
	end 
	
	def self.import_csv(file)
	    csv_text = File.read('file')
        csv = CSV.parse(csv_text, :headers => true)
        csv.each do |row|
            Moulding.create!(row.to_hash)
        end
	end 
end
