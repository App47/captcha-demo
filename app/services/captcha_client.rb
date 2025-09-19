require "faraday"
require "json"

class CaptchaClient
  API_TIMEOUT = 10

  def fetch_nonce
    jwt_token = signer.sign

    conn = faraday
    res = conn.get(captcha_api_url(:nonce), {}, { "Authorization": jwt_token })
    raise "Nonce Request #{res.status}" unless res.success?

    json = JSON.parse(res.body) rescue {}
    json["nonce"] || raise("Nonce missing in response")
  rescue StandardError => error
    puts error.inspect
    status = error.response&.dig(:status)
    body   = error.response&.dig(:body).to_s
    msg    = safe_error_message(body)
    raise(msg.presence || "Nonce request failed#{status ? " (#{status})" : ""}")
  end

  def verify_reset!(token:, nonce:)
    jwt_token = signer.sign({ token: token, nonce: nonce })

    conn = faraday
    res = conn.get(captcha_api_url(:validate), {}, { "Authorization": jwt_token })
    raise "Verification Request #{res.status}" unless res.status == 204
  rescue StandardError => error
    status = error.response&.dig(:status)
    body   = error.response&.dig(:body).to_s
    msg    = safe_error_message(body)
    raise(msg.presence || "Verification request failed#{status ? " (#{status})" : ""}")
  end

  private

  def captcha_api_url(endpoint)
    "#{captcha_api}#{endpoint}"
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

  def safe_error_message(body)
    begin
      parsed = JSON.parse(body)
      parsed['message'] || parsed['error'] || body
    rescue
      body
    end
  end

end