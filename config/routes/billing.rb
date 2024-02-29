namespace :subscriptions do
  resource :stripe, controller: :stripe, only: [:show]
  resource :paddle_billing, controller: :paddle_billing, only: [:show, :edit]
  resource :paddle_classic, controller: :paddle_classic, only: [:show]
end
resources :subscriptions do
  collection do
    patch :billing_settings
  end
  resource :payment_method, module: :subscriptions
  resource :cancel, module: :subscriptions
  resource :pause, module: :subscriptions
  resource :resume, module: :subscriptions
  resource :upcoming, module: :subscriptions
end
resources :charges do
  member do
    get :invoice
  end
end
