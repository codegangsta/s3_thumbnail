$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "s3_thumbnail"
require "s3direct"
require "active_model"
require "aws-sdk"

@fakes3 = Thread.new do
  require "fakes3/cli"
  FakeS3::CLI.start(['--root', File.expand_path('../../tmp/fakes3', __FILE__), '--port', '5678'])
end
sleep(1)

S3Thumbnail.configure do |config|
  S3Direct.config.bucket_url = 'http://localhost:5678/'
  config.bucket = S3Direct.config.bucket = 'specs'
end

AWS.config(
  s3_endpoint: 'localhost',
  s3_port: 5678,
  use_ssl: false,
  s3_force_path_style: true,
  access_key_id: 'YOUR_ACCESS_KEY_ID',
  secret_access_key: 'YOUR_SECRET_ACCESS_KEY'
)
