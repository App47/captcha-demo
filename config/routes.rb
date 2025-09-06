Rails.application.routes.draw do
  root to: "welcome#show"
  resource :demo, only: %i[show create]
  resource :welcome, only: :show
  resource :health_check, only: :show
end