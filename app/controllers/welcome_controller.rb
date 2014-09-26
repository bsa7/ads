class WelcomeController < ApplicationController
#  before_action :set_welcome, only: [:show, :edit, :update, :destroy]
#  respond_to :json, :html

  include ApplicationHelper

  def index
    if params && params[:layout]
      render :index, layout: params[:layout] == "true"
    else
      render :index, layout: true
    end
  end

end
