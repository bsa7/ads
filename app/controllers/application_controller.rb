class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  

	helper_method :render_if
	
	def need_layout params
		if params && params[:layout] && params[:layout].to_s == "false"
			false
		else
			true
		end
	end

end
