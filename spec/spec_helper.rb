$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 's3_thumbnail'
require 's3direct'
require 'active_model'

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
