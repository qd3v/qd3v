require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name        = 'qd3v-testing-core'
  spec.summary     = 'Testing core'
  spec.description = 'Description of the Project'

  spec.author   = 'Ivan Kulagin'
  spec.email    = 'job@kulagin.dev'
  spec.homepage = 'https://kulagin.dev'
  spec.license  = 'Nonstandard'

  spec.metadata['allowed_push_host'] = ''

  spec.version               = Qd3v::Testing::Core::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = Gem::Requirement.new('~> 3.3')

  spec.require_paths = ['lib']
  spec.files         = Dir['lib/**/*.{rb,yml}']

  spec.add_runtime_dependency 'json_expressions'
  spec.add_runtime_dependency 'qd3v-core'
  spec.add_runtime_dependency 'rspec', '~> 3.13'
  spec.add_runtime_dependency 'simplecov'
  spec.add_runtime_dependency 'super_diff'
  spec.add_runtime_dependency 'vcr'
  spec.add_runtime_dependency 'webmock'
end
