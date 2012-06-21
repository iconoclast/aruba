require 'spec_helper'
require 'aruba/config'
require 'aruba/api'
include Aruba::Api

describe "Aruba JRuby Startup Helper"  do
  before(:all) do
    @fake_env = ENV.clone

    @fake_sun_os = Module.new
    @fake_sun_os::CONFIG = RbConfig::CONFIG.merge('host_os' => 'solaris')

    @fake_other_os = Module.new
    @fake_other_os::CONFIG = RbConfig::CONFIG.merge('host_os' => 'moon')
  end
  before(:each) do
    Aruba.config = Aruba::Config.new
    @fake_env['JRUBY_OPTS'] = "--1.9"
    @fake_env['JAVA_OPTS'] = "-Xdebug"
  end

  it 'configuration does not load when RUBY_PLATFORM is not java' do
    with_constants :ENV => @fake_env, :RUBY_PLATFORM => 'x86_64-chocolate' do
      load 'aruba/jruby.rb'
      Aruba.config.hooks.execute :before_cmd, self
      ENV['JRUBY_OPTS'].should  == "--1.9"
      ENV['JAVA_OPTS'].should  == "-Xdebug"
    end
  end

  it 'configuration loads for java and merges existing environment variables' do
    with_constants :ENV => @fake_env, :RUBY_PLATFORM => 'java', :RbConfig => @fake_sun_os do
      load 'aruba/jruby.rb'
      Aruba.config.hooks.execute :before_cmd, self
      ENV['JRUBY_OPTS'].should  == "-X-C --1.9"
      ENV['JAVA_OPTS'].should  == "-d32 -Xdebug"
    end
  end

  it 'configuration loads without breaking java on non-Solaris systems' do
    with_constants :ENV => @fake_env, :RUBY_PLATFORM => 'java', :RbConfig => @fake_other_os do
      load 'aruba/jruby.rb'
      Aruba.config.hooks.execute :before_cmd, self
      ENV['JRUBY_OPTS'].should  == "-X-C --1.9"
      ENV['JAVA_OPTS'].should  == "-Xdebug"
    end
  end
end
