Rails.application.routes.draw do
	scope "/объявления" do
		post '/upload_image' => 'images#upload'
		post '/add_ads' => 'classified_ads#create'
		get '/ad/:id(.:format)' => 'classified_ads#show'
		get '/index_channel' => 'classified_ads#index_channel'
		get '/close_index_channel' => 'classified_ads#close_index_channel'
		root 'classified_ads#index'
	end
end
