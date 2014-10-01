class ImagesController < ApplicationController

	require 'fileutils'
	include ApplicationHelper

	def upload
		up_dir = "/public/system/uploads"
		sourceDir = "#{Rails.root}#{up_dir}/#{params[:ads_id][-2..-1].downcase}"
		FileUtils.mkdir_p sourceDir
		FileUtils.chown 'slon', 'nginx', sourceDir
		FileUtils.chmod 0755, sourceDir
		destFileName = "#{sourceDir}/#{params[:file_name]}"
		
		if request.body.class == StringIO
			file = Tempfile.new(['temp',''])
			file.binmode
			file.write request.body.read
			source = file.path
		else
			source = request.body.path
		end
		FileUtils.mv source, destFileName
		FileUtils.chown 'slon', 'nginx', destFileName
		FileUtils.chmod 0660, destFileName
		render json: {filename: destFileName.gsub("#{Rails.root}#{up_dir}", '')}
	end

end
