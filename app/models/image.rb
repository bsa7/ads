class Image < ActiveRecord::Base
	belongs_to :classified_ads
	has_attached_file :photo
end
