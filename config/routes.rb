Rails.application.routes.draw do

=begin
	#Так тоже можно, но не интересно
	resources :classified_ads do
		resources :images
	end
=end

	post '/upload_image' => 'images#upload'
	post '/add_ads' => 'classified_ads#create'
	get '/ad/:id(.:format)' => 'classified_ads#show'
	root 'classified_ads#index'
end
