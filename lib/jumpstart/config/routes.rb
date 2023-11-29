Jumpstart::Engine.routes.draw do
  resource :admin, only: [:show]
  resource :config, only: [:create]
  resources :users, only: [:create]

  resource :docs do
    # Get Started
    get :installation
    get :configuration
    get :upgrading
    get :deploying
    get :screencasts

    # Users
    get :authentication
    get :accounts
    get :roles
    get :billing
    get :multitenancy

    # Payments
    get :subscriptions
    get :one_time_payments

    # Backend
    get :action_cable
    get :action_mailbox
    get :action_text
    get :active_storage
    get :admin
    get :announcements
    get :api
    get :api_clients
    get :background_workers
    get :credentials
    get :cron
    get :databases
    get :email
    get :i18n
    get :notifications
    get :oauth
    get :scaffolds

    # Frontend
    get :branding
    get :javascript
    get :tailwind
    get :typography

    # Components
    get :alerts
    get :buttons
    get :cards
    get :clipboard
    get :forms
    get :icons
    get :modals
    get :pagination
    get :pills
    get :tabs
    get :tooltips
    get :slideover
    get :wells

    get :business
    get :existing_apps
    get :integrations
  end

  root to: "admin#show"
end
