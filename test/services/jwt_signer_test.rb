# frozen_string_literal: true

require "./test/test_helper"

class JwtSignerTest < Minitest::Test
  JwtSecrets = Struct.new(:issuer, :audience, :private_key_pem, :kid, keyword_init: true)

  def setup
    @kid      = "kid-#{SecureRandom.hex(8)}"
    @issuer   = "https://example.test"
    @audience = "aud-#{SecureRandom.hex(4)}"

    ec = OpenSSL::PKey::EC.generate("prime256v1")
    @ec_private_key_pem = ec.to_pem
    @public_ec = ec.public_key
  end

  def test_sign_returns_valid_jwt_with_expected_header
    token = sign

    header, _payload = decode_header_and_payload_without_verification(token)
    assert_equal "ES256", header["alg"]
    assert_equal "JWT",   header["typ"]
    assert_equal @kid,    header["kid"]
  end

  def test_sign_includes_default_claims_and_additional_claims
    now_before = Time.now.to_i
    token = sign("sub" => "user-123", "scope" => "read:all")
    _header, payload = decode_header_and_payload_without_verification(token)

    assert_equal @issuer, payload["iss"]
    assert_equal @audience, payload["aud"]
    assert payload["iat"].is_a?(Integer)
    assert payload["iat"] >= now_before
    assert_equal "user-123", payload["sub"]
    assert_equal "read:all", payload["scope"]
  end

  def test_signature_verifies_with_public_key
    token = sign("sub" => "abc")

    decoded_payload, decoded_header = JWT.decode(
      token,
      @public_ec,
      true,
      {
        algorithm: "ES256",
        verify_aud: false,
        verify_iss: false
      }
    )

    assert_equal "abc", decoded_payload["sub"]
    assert_equal @issuer, decoded_payload["iss"]
    assert_equal @audience, decoded_payload["aud"]
    assert_equal "ES256", decoded_header["alg"]
    assert_equal @kid, decoded_header["kid"]
  end

  def test_raises_when_private_key_missing
    assert_raises(StandardError) do
      sign_with(nil)
    end
  end

  def test_raises_when_private_key_is_not_ec
    rsa = OpenSSL::PKey::RSA.generate(2048)
    error = assert_raises(ArgumentError) { sign_with(rsa.to_pem) }
    assert_match "jwt.private_key_pem", error.message
  end

  private

  def sign(claims = {})
    sign_with(@ec_private_key_pem, claims)
  end

  def sign_with(pem, claims = {})
    secrets = JwtSecrets.new(
      issuer: @issuer,
      audience: @audience,
      private_key_pem: pem,
      kid: @kid
    )
    creds = Rails.application.credentials
    creds.define_singleton_method(:jwt) { secrets }
    JwtSigner.new.sign(claims)
  ensure
    creds.singleton_class.send(:remove_method, :jwt) if creds&.singleton_methods.include?(:jwt)
  end

  def decode_header_and_payload_without_verification(token)
    segments = token.split(".")
    header_json = Base64.urlsafe_decode64(pad_b64(segments[0]))
    payload_json = Base64.urlsafe_decode64(pad_b64(segments[1]))
    [JSON.parse(header_json), JSON.parse(payload_json)]
  end

  def pad_b64(str)
    str + "=" * ((4 - str.length % 4) % 4)
  end
end
