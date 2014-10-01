class ClassifiedAdsController < ApplicationController

	include ApplicationHelper
	include ActionController::Live

# ***********************************************************************************************
	def index_channel
		notify_client
	end

# ***********************************************************************************************
	def init_index_channel
		response.headers['Content-Type'] = 'text/event-stream'
		response.headers['Cache-Control'] = 'no-cache'
	end

# ***********************************************************************************************
	def last_ads_datetime
		ClassifiedAd.redis.hget "LatestAds", "datetime"
	end

# ***********************************************************************************************
	def notify_client
		init_index_channel
		ads_timestamp = last_ads_datetime #this var used because IOError will be trown if try to use call from stream.write moment
		begin
			response.stream.write("id: #{Time.now}\n\n")
			response.stream.write("retry: 1000\n\n")
			response.stream.write("data: #{ads_timestamp}\n\n")
		rescue => e
			Rails.logger.debug "Raise error at notify_client #{'=='*88}"
			Rails.logger.debug e.inspect
		end
	end

# ***********************************************************************************************
	def close_index_channel
		response.stream.close
	end

# ***********************************************************************************************
	def create
		ActiveRecord::Base.transaction do
			@ads = ClassifiedAd.create(
				plain_text: params[:ads_text]
			)
			if params[:ads_images]
				params[:ads_images].each do |key, value|
					@ads.images << Image.create({
						comment: value["comment"],
						filename: "#{value['id'][-2..-1].downcase}/#{value['filename']}"
					})
				end
			end
			@ads.save!
		end
		ClassifiedAd.redis.hset "LatestAds", "datetime", @ads.created_at
		render json: {ads_text: params[:ads_text], other: params}
	end

# ***********************************************************************************************
	def index
		if params && params[:timezone]
			@client_timezone = params[:timezone] || "UTC"
			date = Time.at((params[:older_than] || params[:later_than]).to_i/1000).in_time_zone("UTC").strftime("%Y-%m-%d %H:%M:%S")
		end
		if params && params[:count]
			count = params[:count] || Count_of_ads
		end
		if params && (params[:older_than] || params[:later_than])
			@classified_ads = ClassifiedAd.where("created_at #{params[:older_than] ? '<' : '>'} '#{date}'").order('created_at DESC').limit(Count_of_ads)
		else
			@classified_ads = ClassifiedAd.order('created_at DESC').limit(Count_of_ads)
		end
		render layout: need_layout(params)
	end
	
# ***********************************************************************************************
	def show
		set_ad
		render layout: need_layout(params)
	end

# ***********************************************************************************************
	private

	def set_ad
		@ad = ClassifiedAd.find(params[:id])
	end

	def ad_params
		params.require(:classified_ad).permit( :plain_text, :images)
	end

end
