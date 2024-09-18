ENV['APP_ENV']           = 'test'
ENV['APP_LOG_LEVEL']     = 'debug'
# Triggering eager load
ENV['APP_TEST_COVERAGE'] = '1'

require 'qd3v/core'

Qd3v::Core::Container.start(:logger)

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }
