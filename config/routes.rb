Rails.application.routes.draw do
  namespace :babelabel do
    resources :translations, :controller => 'translations', :constraints => { :id => /[^\/]+/ } do
      collection do
        post :reset_last_seen
        post :delete_unseen
      end
    end

    match "/assets/:asset(.:format)", :to => "assets#show"
  end
end