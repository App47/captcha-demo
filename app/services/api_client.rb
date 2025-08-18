require "faraday"
require "json"

class ApiClient
  API_TIMEOUT = 5

  def initialize(base_url: ENV["API_BASE_URL"])
    @base_url = base_url.to_s.sub(%r{\/+$}, "") # trim trailing slash
  end

  def fetch_nonce
    token = signer.sign({ purpose: "nonce" }, exp_seconds: 30)

    conn = faraday
    res = conn.get("#{@base_url}/nonce") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.headers["Accept"] = "application/json"
    end

    raise "Nonce HTTP #{res.status}" unless res.success?

    json = JSON.parse(res.body) rescue {}
    json["nonce"] || raise("Nonce missing in response")
  end

  def verify_reset(email:, nonce:)
    token = signer.sign({ purpose: "verify", email: email, nonce: nonce }, exp_seconds: 60)

    conn = faraday
    res = conn.post("#{@base_url}/verify") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.headers["Content-Type"] = "application/json"
      req.headers["Accept"] = "application/json"
      req.body = JSON.dump({ email: email, nonce: nonce })
    end

    return false unless res.success?

    json = JSON.parse(res.body) rescue {}
    json["success"] == true
  end

  private

  def signer
    @signer ||= JwtSigner.new
  end

  def faraday
    @faraday ||= Faraday.new(request: { timeout: API_TIMEOUT, open_timeout: API_TIMEOUT }) do |f|
      # Lightweight resilience
      f.request :retry,
                max: 2,
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