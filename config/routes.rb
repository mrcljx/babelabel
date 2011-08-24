Rails.application.routes.draw do |map|
  resources :translations, :controller => 'babelabel/translations', :constraints => { :id => /[^\/]+/ } do
    collection do
      post :reset_last_seen
      post :delete_unseen
    end
  end
end