require 'rubygems' unless ENV['NO_RUBYGEMS']

begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'alsa'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
