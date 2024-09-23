ENV['APP_ENV']                       = 'test'
ENV['APP_LOG_LEVEL']                 = 'debug'
ENV['QD3V_OPENAI_FARADAY_LOG_DEBUG'] = 'yes'

require 'benchmark'
# 1.481145 seconds
puts(Benchmark.measure {
  require 'bundler/setup'
  Bundler.require(:default, :test)
})

# NOTE: In order to webmock start rspec as dep, we need to register both
#       BTW, internally will start logger
Qd3v::OpenAI::Container.register_provider(:rspec, from: :qd3v_testing_core)
Qd3v::OpenAI::Container.register_provider(:webmock, from: :qd3v_testing_core)
Qd3v::OpenAI::Container.start(:webmock)

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }
