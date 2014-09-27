class ImagesController < ApplicationController

  require 'fileutils'
  include ApplicationHelper

  def upload
    up_dir = "/public/system/uploads"
    sourceDir = "#{Rails.root}#{up_dir}/#{params[:ads_id][-2..-1].downcase}"
    FileUtils.mkdir_p sourceDir
    destFileName = "#{sourceDir}/#{params[:file_name]}"
    FileUtils.cp request.body.path, destFileName
    render json: {filename: destFileName.gsub("#{Rails.root}#{up_dir}", '')}
  end

end
