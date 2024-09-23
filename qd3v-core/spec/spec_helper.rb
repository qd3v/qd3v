ENV['APP_ENV']           = 'test'
ENV['APP_LOG_LEVEL']     = 'debug'
ENV['APP_TEST_COVERAGE'] = 'no'

require 'qd3v/testing/core'

Qd3v::Core::Container.register_provider(:rspec, from: :qd3v_testing_core)
Qd3v::Core::Container.start(:rspec)

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }
