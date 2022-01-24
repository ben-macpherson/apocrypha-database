class Location < ApplicationRecord
	has_many :ownerships
	has_many :booklets
	has_many :booklists
	has_many :modern_sources
	belongs_to :city_orig_language, class_name: "Language", optional: true
	belongs_to :region_orig_language, class_name: "Language", optional: true
	belongs_to :diocese_orig_language, class_name: "Language", optional: true

	def city_region_country
		self.city_english + ', ' + self.region_english + ', ' + self.country  
	end
end
