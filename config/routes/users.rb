devise_for :users,
  controllers: {
    omniauth_callbacks: ("users/omniauth_callbacks" if defined? OmniAuth),
    registrations: "users/registrations",
    sessions: "users/sessions"
  }.compact

devise_scope :user do
  get "session/otp", to: "sessions#otp"
end

namespace :account do
  resource :password
end
namespace :users do
  resources :mentions, only: [:index]
end
namespace :user, module: :users do
  resource :two_factor, controller: :two_factor do
    get :backup_codes
    get :verify
  end
  resources :connected_accounts
end

resources :agreements, module: :users
resources :notifications, only: [:index, :show] do
  collection do
    patch :mark_as_read
  end
end

resources :referrals, module: :users if defined? Refer

post :sudo, to: "users/sudo#create"
