namespace :admin do
  if defined?(Sidekiq)
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
  mount MissionControl::Jobs::Engine, at: "/jobs" if defined?(::MissionControl::Jobs::Engine)
  mount Flipper::UI.app(Flipper) => "/flipper" if defined?(::Flipper::UI)

  resources :announcements
  resources :users do
    resource :impersonate, module: :user
  end
  resources :connected_accounts
  resources :accounts
  resources :account_users
  resources :plans
  namespace :pay do
    resources :customers
    resources :charges
    resources :payment_methods
    resources :subscriptions
  end

  root to: "dashboard#show"
end
