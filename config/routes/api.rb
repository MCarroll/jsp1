namespace :api, defaults: {format: :json} do
  namespace :v1 do
    resource :auth
    resource :me, controller: :me
    resource :password
    resources :accounts
    resources :users
    resources :notification_tokens, only: :create
  end
end

resources :api_tokens
