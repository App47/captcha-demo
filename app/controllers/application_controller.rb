# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # If you have JSON endpoints and want to opt-out of CSRF for them:
  # protect_from_forgery unless: -> { request.format.json? }
end
