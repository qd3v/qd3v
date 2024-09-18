require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name        = 'qd3v-openai'
  spec.summary     = 'Summary of the Project'
  spec.description = 'Description of the Project'

  spec.author   = 'Ivan Kulagin'
  spec.email    = 'job@kulagin.dev'
  spec.homepage = 'https://kulagin.dev'
  spec.license  = 'Nonstandard'

  spec.metadata['allowed_push_host'] = ''

  spec.version               = Qd3v::OpenAI::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = Gem::Requirement.new('~> 3.3')

  spec.add_runtime_dependency 'faraday-retry'
  spec.add_runtime_dependency 'qd3v-core'
  spec.add_runtime_dependency 'ruby-openai'

  spec.require_paths = ['lib']
  spec.files         = Dir['lib/**/*.{rb,yml}']
end
