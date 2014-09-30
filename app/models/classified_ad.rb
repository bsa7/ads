class ClassifiedAd < ActiveRecord::Base
	has_many :images
	include Redis::Objects
end
