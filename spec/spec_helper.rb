$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "s3_thumbnail"
require "s3direct"
require "active_model"
require "aws-sdk"

@fakes3 = Thread.new do
  require 'fakes3/cli'
  FakeS3::CLI.start(['--root', Rails.root.join('tmp/fakes3'), '--port', '5678', '--silent'])
end

S3Thumbnail.configure do |config|
  S3Direct.config.bucket_url = 'http://localhost:5678/'
  config.bucket = S3Direct.config.bucket = 'specs'
end

AWS.config(
  s3_endpoint: 'localhost',
  s3_port: 5678,
  use_ssl: false,
  s3_force_path_style: true
)

RSpec.configure do |config|
  # Stolen from braintree/curator.  Allows creating classes in specs
  # that won't pollute after the fact
  config.around(:each) do |test|
    @transient_classes = []
    test.call
    @transient_classes.each do |name|
      begin
        Object.send(:remove_const, name)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
  end

  def def_transient_class(name, &block)
    @transient_classes << name
    raise("Cannot define transient class, constant #{name} is already defined") if Object.const_defined?(name)
    Object.const_set name, Class.new(&block)
  end

  def add_transient_subclass(name, parent_class, &block)
    @transient_classes << name
    if block_given?
      Object.const_set name, Class.new(parent_class, &block)
    else
      Object.const_set name, Class.new(parent_class)
    end
  end
end
