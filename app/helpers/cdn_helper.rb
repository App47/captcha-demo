
module CdnHelper
  # @abstract Combine the CDN URL with the given path.
  # @param [String] path the path to load from the CDN.
  # @return [String]
  def cdn_url(path)
    [Rails.application.credentials.cdn_url, path].join('/')
  end
end
