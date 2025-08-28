require "faraday"
require "json"

class CaptchaClient
  API_TIMEOUT = 10

  def fetch_nonce
    token = signer.sign

    conn = faraday
    res = conn.get(captcha_api_url(:nonce, token))
    raise "Nonce Request #{res.status}" unless res.success?

    json = JSON.parse(res.body) rescue {}
    json["nonce"] || raise("Nonce missing in response")
  end

  def verify_reset!(token:, nonce:)
    jwt_token = signer.sign({ token: token, nonce: nonce })

    conn = faraday
    res = conn.get(captcha_api_url(:validate, jwt_token))
    unless res.success?
      json = JSON.parse(res.body)
      raise json['message']
    end
  end

  private

  def captcha_api_url(endpoint, jwt)
    "#{captcha_api}/#{endpoint}?jwt=#{jwt}"
  end

  def captcha_api
    @captcha_api ||= Rails.application.credentials.jwt.api_url
  end

  def signer
    @signer ||= JwtSigner.new
  end

  def faraday
    @faraday ||= Faraday.new(request: { timeout: API_TIMEOUT, open_timeout: API_TIMEOUT }) do |f|
      # Lightweight resilience
      f.request :retry,
                max: 4,
                interval: 0.25,
                backoff_factor: 2,
                retry_statuses: [429, 500, 502, 503, 504]
      # Optionally follow redirects if your API uses them:
      # f.response :follow_redirects
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end
  end
end