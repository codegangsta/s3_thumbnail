require "active_support/all"

require "s3_thumbnail/version"
require "s3_thumbnail/generation"
require "s3_thumbnail/thumbnailable"

module S3Thumbnail
  def self.configure
    yield config
  end

  def self.config
    @@config ||= Config.new
  end

  class Config
    attr_accessor :bucket
  end
end
