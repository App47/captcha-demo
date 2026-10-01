# captcha-demo

Rails example of the App47 Captcha service, shown as a password-reset form.

The page loads the captcha widget from the CDN. The server signs an ES256 JWT to start the challenge, then signs a second JWT to validate the token the widget returns. A working copy of each step is in this repo:

* Widget markup: [app/views/demos/show.html.erb](app/views/demos/show.html.erb)
* Widget script: [app/views/layouts/application.html.erb](app/views/layouts/application.html.erb)
* Start and submit: [app/controllers/demos_controller.rb](app/controllers/demos_controller.rb)
* API calls: [app/services/captcha_client.rb](app/services/captcha_client.rb)
* JWT signing: [app/services/jwt_signer.rb](app/services/jwt_signer.rb)

## Credentials

Rails credentials hold the API location and the signing key. `jwt.api_url` needs a trailing slash, because the client appends `nonce` and `validate` directly.

```yaml
jwt:
  api_url: https://captcha.app47.net/
  issuer: your-issuer
  audience: your-audience
  private_key_pem: |
    -----BEGIN EC PRIVATE KEY-----
    ...
    -----END EC PRIVATE KEY-----
  kid: your-key-id
cdn_url: https://your-cdn.example/
```

The private key is an EC key on P-256. The widget script and stylesheet are loaded from `cdn_url` as `widget.min.js` and `widget.min.css`.

## Browser setup

Load the widget script on the page:

```html
<script src="https://your-cdn.example/widget.min.js"></script>
```

Put the widget in the form. The server passes a JWT that already contains the nonce (see below). The widget writes the solved token and the nonce into the hidden fields named here.

```html
<cap-widget id="cap"
            data-cap-api-endpoint="https://captcha.app47.net/"
            data-cap-css-url="https://your-cdn.example/widget.min.css"
            data-cap-token-field-name="cap_token"
            data-cap-nonce-field-name="cap_nonce"
            data-cap-jwt-token="SIGNED_JWT_WITH_NONCE">
</cap-widget>
```

On submit, the form sends `cap_token` and `cap_nonce` with the rest of the fields. This demo also sends `email`.

## Server flow

Every call is a `GET` with `Authorization: Bearer <jwt>`. The JWT uses `ES256`. The header carries `kid`. The payload always includes `iss`, `aud`, and `iat` from the credentials above.

1. Sign a JWT with only those default claims and `GET {api_url}nonce`. The JSON body contains `nonce`.
2. Sign a second JWT that adds `nonce`, and pass that token to the widget as `data-cap-jwt-token`.
3. When the form is submitted, require the nonce and the token. Sign a third JWT that adds both `token` and `nonce`, and `GET {api_url}validate`.
4. HTTP 204 means the captcha is valid. Any other status is a failure.

`CaptchaClient#fetch_nonce` and `CaptchaClient#verify_reset!` are the reference for steps 1 and 3.
