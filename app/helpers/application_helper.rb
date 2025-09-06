module ApplicationHelper
  # @abstract Combine the CDN URL with the given path.
  # @param [String] path the path to load from the CDN.
  # @return [String]
  def cdn_url(path)
    URI.join(Rails.application.credentials.cdn_url, path).to_s
  end

  def env_var(key, default = nil)
    ENV[key].presence || default
  rescue StandardError
    default
  end
end
