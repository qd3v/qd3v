lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "qd3v/core/version"

Gem::Specification.new do |spec|
  spec.name        = 'qd3v-core'
  spec.summary     = 'Base microframework for my pet projects'
  spec.description = 'Description of the Project'

  spec.author   = 'Ivan Kulagin'
  spec.email    = 'job@kulagin.dev'
  spec.homepage = 'https://kulagin.dev'
  spec.license  = 'Nonstandard'

  spec.metadata['allowed_push_host'] = ''

  spec.version               = Qd3v::Core::VERSION.dup
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = Gem::Requirement.new('~> 3.3')

  spec.add_runtime_dependency 'activesupport', '~> 8.0'

  spec.add_runtime_dependency 'i18n'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'ruby-enum'
  spec.add_runtime_dependency 'zeitwerk'

  spec.add_runtime_dependency 'amazing_print'
  spec.add_runtime_dependency 'semantic_logger'

  spec.add_runtime_dependency 'dotenv'
  spec.add_runtime_dependency 'env_bang'
  spec.add_runtime_dependency 'sorbet-runtime'

  spec.add_runtime_dependency 'dry-configurable'
  spec.add_runtime_dependency 'dry-initializer'
  spec.add_runtime_dependency 'dry-monads'
  spec.add_runtime_dependency 'dry-schema'
  spec.add_runtime_dependency 'dry-system'
  spec.add_runtime_dependency 'dry-types'

  spec.require_paths = ['lib']
  spec.files         = Dir['lib/**/*.{rb,yml}']
end
