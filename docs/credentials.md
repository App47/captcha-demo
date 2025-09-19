# Credentials.md

Rails Credentials: what they are, how to set them up, how to edit safely, and how to use them in your app.

Overview

- Rails credentials provide encrypted, version-controlled storage for secrets (API keys, passwords, endpoints).
- The encrypted data lives in config/credentials/*.yml.enc.
- The decryption keys live in config/credentials/*.key and must NOT be committed. In production, provide the key via environment variable (RAILS_MASTER_KEY or the per-env equivalent).

Key concepts

- Encrypted files (.yml.enc): Safe to commit.
- Key files (.key): DO NOT COMMIT. Provide at runtime via env vars.
- Per-environment credentials: Rails 6+ supports separate files for development, test, and production (and any custom env).

Typical files

- config/credentials.yml.enc (legacy “global” credentials)
- config/credentials/development.yml.enc
- config/credentials/test.yml.enc
- config/credentials/production.yml.enc
- config/credentials/development.key, test.key, production.key (DO NOT COMMIT)

Quick start: create/edit per-environment credentials

1) Choose your editor

```
bash
# bash
export EDITOR="code --wait"   # VS Code
# or: export EDITOR="vim"
# or: export EDITOR="nano"
```

2) Create or edit the credentials for an environment

```
bash
# bash
bin/rails credentials:edit --environment development
bin/rails credentials:edit --environment test
bin/rails credentials:edit --environment production
```

- This decrypts to a temporary YAML file, opens your editor, and re-encrypts on save and exit.
- If the .key file is missing, Rails will generate it for you.

3) Add secrets as YAML

```
yaml
# yaml
jwt:
api_url: https://captcha.app47.net/
some_api_key: "abc123"
nested:
token: "xyz"
```

4) Use in the app

```
ruby
# ruby
Rails.application.credentials.jwt[:api_url]
Rails.application.credentials.dig(:nested, :token)
Rails.application.credentials[:some_api_key]
```

Viewing credentials (read-only)

```
bash
# bash
bin/rails credentials:show --environment development
```

Production and CI/CD: providing the key

- In production, do NOT deploy the .key file with your app. Instead, set:
  - RAILS_MASTER_KEY for global credentials (config/credentials.yml.enc), or
  - RAILS_MASTER_KEY for per-environment credentials as well (Rails uses this for the current RAILS_ENV’s file).

- Common ways to provide the key:
  - As an environment variable in your container/task definition (e.g., ECS task secret from SSM).
  - As a secret in your CI pipeline that’s injected at runtime.
  - From a secret manager (AWS SSM Parameter Store, Secrets Manager, Vault, etc.).

Example: using AWS SSM Parameter Store for the key

- Store the key at parameter name /myapp/rails_master_key.
- Grant your runtime role permission to read it (ssm:GetParameter) and kms:Decrypt.
- Inject into the container as env RAILS_MASTER_KEY via the task definition.

Git hygiene
- Commit: *.yml.enc files.
- Never commit: *.key files.
- .gitignore should include:

```

config/master.key
config/credentials/*.key
```

Migrating from single to per-environment credentials

- If you currently use config/credentials.yml.enc:
  - Create environment-specific credentials with the commands above.
  - Move entries into the appropriate per-env files.
  - Update code to reference the same keys (no change needed if keys are the same).
  - Ensure you provide RAILS_MASTER_KEY at runtime for that environment.

Common patterns

- Namespaced keys per feature:

```
yaml
# yaml
captcha:
api_url: https://captcha.app47.net/
public_key: pk_xxx
secret_key: sk_xxx
```

- Access in code:

```
ruby
# ruby
Rails.application.credentials.dig(:captcha, :api_url)
Rails.application.credentials.dig(:captcha, :secret_key)
```

Troubleshooting

- “Missing encryption key to decrypt file”:
  - Ensure RAILS_MASTER_KEY is set in the environment (echo $RAILS_MASTER_KEY).
  - Ensure the key corresponds to the correct .yml.enc file for the current RAILS_ENV.
- “Could not find editor”:
  - Set EDITOR as shown above.
- Credential changes don’t take effect:
  - Restart the app (secrets are typically read at boot).
- CI cannot decrypt:
  - Confirm the secret env var is present in the job logs (masked).
  - Confirm the correct RAILS_ENV and matching key.

Security tips

- Prefer per-environment credentials; never reuse production secrets elsewhere.
- Limit access to .key files and secret env variables to least-privilege.
- Avoid printing secrets in logs or exposing them via environment endpoints.

Useful links

- Rails Guides: Credentials
  - https://guides.rubyonrails.org/security.html#custom-credentials
- Rails API docs: Rails.application.credentials
  - https://api.rubyonrails.org/classes/Rails/Application.html#method-i-credentials
- Blog: Understanding Rails Credentials
  - https://edgeguides.rubyonrails.org/security.html#custom-credentials (edge)
  - https://www.honeybadger.io/blog/rails-encrypted-credentials/
