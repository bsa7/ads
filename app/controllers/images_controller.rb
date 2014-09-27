class ImagesController < ApplicationController

	require 'fileutils'
	include ApplicationHelper

	def upload
		up_dir = "/public/system/uploads"
		sourceDir = "#{Rails.root}#{up_dir}/#{params[:ads_id][-2..-1].downcase}"
		FileUtils.mkdir_p sourceDir
		destFileName = "#{sourceDir}/#{params[:file_name]}"
		Rails.logger.debug "================"
		Rails.logger.debug request.body.inspect
		
		if request.body.class == StringIO
			file = Tempfile.new(['temp',''])
			file.binmode
			file.write request.body.read
			source = file.path
		else
			source = request.body.path
		end
		FileUtils.mv source, destFileName
		render json: {filename: destFileName.gsub("#{Rails.root}#{up_dir}", '')}
	end

end
