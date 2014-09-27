class ClassifiedAdsController < ApplicationController

	include ApplicationHelper

	def create
		ActiveRecord::Base.transaction do
			@ads = ClassifiedAd.create(
				plain_text: params[:ads_text]
			)
			params[:ads_images].each do |key, value|
				@ads.images << Image.create({
					comment: value["comment"],
					filename: "#{value['id'][-2..-1].downcase}/#{value['filename']}"
				})
			end
			@ads.save!
		end
		render json: {ads_text: params[:ads_text], other: params}
	end

	def index
		@classified_ads = ClassifiedAd.order('created_at DESC').limit(Count_of_ads)
	end
	
	def show
		set_ad
	end


	private

	def set_ad
		@ad = ClassifiedAd.find(params[:id])
	end

	def ad_params
		params.require(:classified_ad).permit( :plain_text, :images)
	end

end
