class ResetPasswordsController < ApplicationController
  def new
    client = CaptchaClient.new
    @jwt_token = signer.sign({ nonce: client.fetch_nonce })
  rescue StandardError => error
    Rails.logger.error("Nonce fetch failed: #{error.class} - #{error.message}")
    flash.now[:alert] = "Unable to start reset flow. Please try again."
    @jwt_token = nil
  end

  def create
    @email = params[:email].to_s.strip
    @nonce = params[:cap_nonce].to_s
    @token = params[:cap_token].to_s
    raise 'Email, nonce and token are required' if @email.blank? || @nonce.blank? || @token.blank?

    client = CaptchaClient.new
    client.verify_reset!(token: @token, nonce: @nonce)
    render :success
  rescue StandardError => error
    Rails.logger.error("Verification failed: #{error.class} - #{error.message}")
    render :error, error_message: error.message
  end

  private

  def signer
    @signer ||= JwtSigner.new
  end
end