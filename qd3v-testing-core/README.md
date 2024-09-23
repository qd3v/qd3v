# `qd3v-testing-core` gem

- preconfigured RSpec/Webmock/VCR providers
- pluggable simplecov with `APP_TEST_COVERAGE` env var or using config
- though there are `vcr` and `webmock` deps, I'm using them so often, that keep together. They are loaded on-demand anyway
- autoloading of helpers from `rspec/support`
- `it { logger.info }` logger injected
- activesupport time helpers
- ...

# Providers dependencies

`vcr -> webmock -> rspec -> core.logger`

# Example `rspec_helper`

```ruby
# Register what you need 
Qd3v::OpenAI::Container.register_provider(:rspec, from: :qd3v_testing_core)
Qd3v::OpenAI::Container.register_provider(:webmock, from: :qd3v_testing_core)
Qd3v::OpenAI::Container.register_provider(:vcr, from: :qd3v_testing_core)

# Starts everything above
Qd3v::OpenAI::Container.start(:vcr)

```

# TODO

- [ ] rename to just `qd3v-testing`?
