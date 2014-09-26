Rails.application.routes.draw do
  post '/upload_image' => 'images#upload'
  root 'welcome#index'
end
