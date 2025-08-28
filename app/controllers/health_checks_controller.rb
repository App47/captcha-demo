class HealthChecksController < ApplicationController
  # GET /health
  def show
    head :ok
  end
end