# `qd3v-testing-core` gem

- preconfigured RSpec/Webmock/VCR providers
- pluggable simplecov with `APP_TEST_COVERAGE` env var or using config
- though there are `vcr` and `webmock` deps, I'm using them so often, that keep together. They are loaded on-demand anyway
- autoloading of helpers from `spec/support`
- `it { logger.info }` logger injected
- activesupport time helpers
- logs `EXAMPLE STARTED/ENDED` marker to help visually detect them in complex tests

# Providers dependencies

`vcr -> webmock -> rspec -> core.logger`

# Example `rspec_helper`

```ruby
# Starts everything above
Qd3v::Testing::Core::Container.start(:rspec)
# or 
Qd3v::Testing::Core::Container.start(:webmock)
# or start all of the above + VCR
Qd3v::Testing::Core::Container.start(:vcr)

```

Each provider start adds `rspec start time * providers count`

# Simplecov

In order to truly measure coverage, eager load code after `SimpleCov.start`
