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
		
		if params && params[:older_than]
			@client_timezone = params[:timezone] || "UTC"
			data = Time.at(params[:older_than].to_i/1000).in_time_zone("UTC").strftime("%Y-%m-%d %H:%M:%S")
			Rails.logger.debug "================= #{params[:older_than]} -> #{data} ======================"
			count = params[:count] || Count_of_ads
			@classified_ads = ClassifiedAd.where("created_at < '#{data}'").order('created_at DESC').limit(Count_of_ads)
		else
			@classified_ads = ClassifiedAd.order('created_at DESC').limit(Count_of_ads)
		end
		Rails.logger.debug @classified_ads.count
		render layout: need_layout(params)
	end
	
	def show
		set_ad
		render layout: need_layout(params)
	end


	private

	def set_ad
		@ad = ClassifiedAd.find(params[:id])
	end

	def ad_params
		params.require(:classified_ad).permit( :plain_text, :images)
	end

end
