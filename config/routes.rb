Rails.application.routes.draw do
  resource :reset_passwords, only: [:new, :create]
  root to: "reset_passwords#new"
  resource :health_check, only: [:show]
end