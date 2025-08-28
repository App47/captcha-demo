require "jwt"
require "securerandom"
require "openssl"

class JwtSigner
  def sign(additional_claims = {})
    header = {
      alg: 'ES256',
      typ: 'JWT',
      kid: kid
    }
    payload = {
      iss: issuer,
      aud: audience,
      iat: Time.now.to_i,
    }.merge(additional_claims)
    puts header.inspect
    puts payload.inspect
    JWT.encode(payload, private_key, 'ES256', header)
  end

  private
  
  def issuer
    @issuer ||= jwt_secrets.issuer
  end
  
  def audience
    @audience ||= jwt_secrets.audience
  end
  
  def private_key
    return @private_key if defined?(@private_key)

    pem = jwt_secrets.private_key_pem
    key = OpenSSL::PKey.read(pem)
    unless key.is_a?(OpenSSL::PKey::EC)
      raise ArgumentError, "JWT_PRIVATE_KEY must be an EC key for ES256"
    end
    @private_key = key
  end
  
  def kid
    @kid ||= jwt_secrets.kid
  end

  def jwt_secrets
    @jwt_secrets ||= Rails.application.credentials.jwt
  end
end