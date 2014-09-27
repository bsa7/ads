Rails.application.routes.draw do
	post '/upload_image' => 'images#upload'
	post '/add_ads' => 'images#create'
	root 'welcome#index'
end
