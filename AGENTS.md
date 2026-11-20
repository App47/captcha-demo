# Repository agent instructions

## Rules of engagement

1. Reference the GitHub story in every commit message using `#storyid` or
   `Org/Repo#storyid`.
2. Start with the simplest change that meets the story.
3. Ask before committing or pushing. Obtain separate approval for each action.
4. Keep documentation concise and consistent with implementation changes.
5. Make AWS changes through GitHub Actions, including Terraform applies.
6. Keep user changes outside the current work intact.

## Role

Maintain the Rails password-reset demo for the App47 Captcha service. Preserve
the demo's browser challenge and server-side validation flow.

## Development tools

- Use the Ruby version in `.ruby-version` and the dependencies in `Gemfile.lock`.
  Check `ruby -v` before running Bundler. Use `rbenv exec` if the shell selects
  macOS system Ruby.
- Install dependencies with `bundle install`. When upgrading Ruby, update the
  Ruby entry in `Gemfile.lock` with `bundle update --ruby`. Keep dependency
  updates scoped to the story.
- Run the suite with `bundle exec rails test`. For the JWT signer tests, run
  `bundle exec rails test test/services/jwt_signer_test.rb`.
- Run `git diff --check` before committing. For Markdown changes, run
  `npx --yes markdownlint-cli2@0.24.1 AGENTS.md`, replacing `AGENTS.md` with the
  paths of the Markdown files you changed.
- Use connected GitHub tools or `gh` to read stories and review feedback.

## Architecture and operations

- Read `README.md` before changing the challenge flow and `docs/credentials.md`
  before changing credentials handling.
- `DemosController` starts the challenge and handles the form submission.
  `CaptchaClient` fetches the nonce and validates the widget token, and
  `JwtSigner` signs the API requests.
- Keep credentials and API tokens out of commits and logs.

## Releases

- Keep `.ruby-version`, `Gemfile`, `Gemfile.lock`, and the Docker build and
  runtime stages on the same Ruby version. Staging CI reads `.ruby-version`.
- The staging workflow tests the app before building and deploying the image.
  A deployment branch must match both the push filters in
  `.github/workflows/staging.yml` and the staging role's GitHub OIDC trust
  policy in `App47/aws-config`.
- The manual production workflow promotes an existing image.
- After a runtime change deploys to staging, open `/demo` on
  `captcha-demo.app47.net`, complete the widget challenge, and submit the form.
  Confirm the success page and check the Ruby version in the running ECS task's
  Puma startup logs.

## Code documentation

- Document behavior and operational constraints that callers need to understand.
- Keep repository guidance focused on durable rules. Track story progress in
  GitHub and keep operational details in `docs/`.
