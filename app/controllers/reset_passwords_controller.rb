class ResetPasswordsController < ApplicationController
  def new
    client = CaptchaClient.new
    @jwt_token = signer.sign({nonce: client.fetch_nonce})
  rescue => error
    Rails.logger.error("Nonce fetch failed: #{error.class} - #{error.message}")
    flash.now[:alert] = "Unable to start reset flow. Please try again."
    @jwt_token = nil
  end

  def create
    email = params[:email].to_s.strip
    nonce = params[:captcha_nonce].to_s
    token = params[:captcha_token].to_s

    if email.blank? || nonce.blank? || token.blank?
      redirect_to new_reset_password_path, alert: "Email, nonce and token are required."
      return
    end

    client = CaptchaClient.new
    verified = client.verify_reset(email: email, nonce: nonce)

    if verified
      redirect_to new_reset_password_path, notice: "Verification successful. Check your email for next steps."
    else
      redirect_to new_reset_password_path, alert: "Verification failed. Please try again."
    end
  rescue => e
    Rails.logger.error("Verification failed: #{e.class} - #{e.message}")
    redirect_to new_reset_password_path, alert: "An error occurred. Please try again."
  end

  private

  def signer
    @signer ||= JwtSigner.new
  end
end