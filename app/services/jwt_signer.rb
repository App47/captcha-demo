require "jwt"
require "securerandom"
require "openssl"

class JwtSigner
  def initialize(issuer: ENV["JWT_ISSUER"], audience: ENV["JWT_AUDIENCE"], private_key_pem: ENV["JWT_PRIVATE_KEY"])
    @issuer = issuer
    @audience = audience
    @private_key = OpenSSL::PKey::RSA.new(private_key_pem.to_s)
  end

  def sign(additional_claims = {}, exp_seconds: 60)
    now = Time.now.to_i
    payload = {
      iss: @issuer,
      aud: @audience,
      iat: now,
      exp: now + exp_seconds,
      jti: SecureRandom.uuid
    }.merge(additional_claims)

    JWT.encode(payload, @private_key, "RS256")
  end
end