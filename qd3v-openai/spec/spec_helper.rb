ENV['APP_ENV']       = 'test'
ENV['APP_LOG_LEVEL'] = 'debug'

require 'benchmark'
# 1.481145 seconds
puts(Benchmark.measure {
  require 'bundler/setup'
  Bundler.require(:default, :test)
})

Qd3v::Testing::Core::Container.start(:rspec) # also starts logger

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }
