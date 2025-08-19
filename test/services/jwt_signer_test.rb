# frozen_string_literal: true

require './test/test_helper'

class JwtSignerTest < Minitest::Test
  def setup
    @kid      = "kid-#{SecureRandom.hex(8)}"
    @issuer   = "https://example.test"
    @audience = "aud-#{SecureRandom.hex(4)}"

    # Generate an EC key on the NIST P-256 curve (required for ES256)
    ec = OpenSSL::PKey::EC.generate("prime256v1")
    @ec_private_key_pem = ec.to_pem
    @ec_public_key_pem = ec.public_to_pem
    @public_ec = ec.public_key

    # Build a pure public key object for verification
    # @public_ec = OpenSSL::PKey::EC.new(ec.group)
    # @public_ec.public_key = ec.public_key

    # Save and set env
    @orig_env = ENV.to_h
    ENV["JWT_KID"] = @kid
    ENV["JWT_PRIVATE_KEY"] = @ec_private_key_pem

    # Set both variants so implementation differences won't break the test
    ENV["JWT_ISS"]     = @issuer
    ENV["JWT_ISSUER"]  = @issuer
    ENV["JWT_AUD"]     = @audience
    ENV["JWT_AUDIENCE"] = @audience
  end

  def teardown
    ENV.replace(@orig_env)
  end

  def test_sign_returns_valid_jwt_with_expected_header
    token = JwtSigner.new.sign

    header, _payload = decode_header_and_payload_without_verification(token)
    assert_equal "ES256", header["alg"]
    assert_equal "JWT",   header["typ"]
    assert_equal @kid,    header["kid"]
  end

  def test_sign_includes_default_claims_and_additional_claims
    now_before = Time.now.to_i
    token = JwtSigner.new.sign("sub" => "user-123", "scope" => "read:all")
    _header, payload = decode_header_and_payload_without_verification(token)

    assert_equal @issuer, payload["iss"]
    assert_equal @audience, payload["aud"]
    assert payload["iat"].is_a?(Integer)
    assert payload["iat"] >= now_before
    assert_equal "user-123", payload["sub"]
    assert_equal "read:all", payload["scope"]
  end

  def test_signature_verifies_with_public_key
    token = JwtSigner.new.sign("sub" => "abc")

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
    ENV.delete("JWT_PRIVATE_KEY")
    assert_raises(StandardError) do
      JwtSigner.new.sign
    end
  end

  def test_accepts_escaped_newlines_in_env
    ENV["JWT_PRIVATE_KEY"] = @ec_private_key_pem.gsub("\n", "\\n")
    token = JwtSigner.new.sign("sub" => "nlines")
    refute_nil token

    # Quick verification still passes with public key
    payload, _hdr = JWT.decode(token, @public_ec, true, algorithm: "ES256", verify_aud: false, verify_iss: false)
    assert_equal "nlines", payload["sub"]
  end

  private

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
