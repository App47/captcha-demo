# app/controllers/errors_controller.rb
# We want to inherit `ActionController::Base` here, not `ApplicationController` because we just want a simple, fast response
# with no extra checks for CSRF,authentication, layouts or the ilk. Just say, no, go away!
class ErrorsController < ActionController::Base
  # No CSRF/layout/filters; keep it cheap
  def not_found
    if defined?(NewRelic) && defined?(NewRelic::Agent)
      NewRelic::Agent.ignore_transaction
    end
    head :gone           # 410 Gone is used here to indicate that the resource has been intentionally and permanently removed, and clients should not expect it to be available again. This is stronger than the standard 404 Not Found, which is used when the resource may be available in the future.
  end
end
