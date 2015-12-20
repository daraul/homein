class Place < ActiveRecord::Base
    belongs_to :user
	has_many :pictures, :dependent => :destroy 
	
	accepts_nested_attributes_for :pictures, :allow_destroy => true
	
	validates_presence_of :price, :rooms, :bathrooms, :description, :for, :address, message: "All fields are required, but pictures aren't." 
	validates_length_of :pictures, maximum: 3, message: "3 or less pictures, please!"
	
	self.per_page = 10
	
    def self.search(query = nil)
        if query
            where("address LIKE :query or description LIKE :query", {query: "%#{query}%"})
        else
            all
        end
    end
    
    def self.filter(parameters = nil)
        filters = {}
    
        if parameters 
            if parameters[:bathrooms]
                if !parameters[:price][:min].blank? && !parameters[:price][:max].blank?
                    filters[:price] = parameters['price']['min'].to_i..parameters['price']['max'].to_i
                end
            end 
            
            if parameters[:rooms]
                if !parameters[:rooms][:min].blank? && !parameters[:rooms][:max].blank?
                    filters[:rooms] = parameters['rooms']['min'].to_i..parameters['rooms']['max'].to_i
                end 
            end 
            
            if parameters[:bathrooms]
                if !parameters[:bathrooms][:min].blank? && !parameters[:bathrooms][:max].blank?
                    filters[:bathrooms] = parameters['bathrooms']['min'].to_i..parameters['bathrooms']['max'].to_i
                end 
            end 
            
            if parameters[:for] && !parameters[:for].blank?
                filters[:for] = parameters[:for].downcase
            end 
            
            where(filters)
        else 
            all
        end 
    end 
end 