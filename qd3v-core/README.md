# `qd3v` gem

- exports `logger` provider
- `Err` class - builds errors
- `EK` - provides i18n for errors (raise if key missing)
- `ENV_BANG` (or alias
  `ENV!`) - small extension of [ENV_BANG](https://github.com/jcamenisch/ENV_BANG) gem: shortcuts like
  `ENV!.test?`, etc.
- main runtime environment defined by
  `APP_ENV` env variable (overwrites RAILS_ENV/RACK_ENV accordingly)
- the same way `DATABASE_URL` is set if `PG_URI` env var present

# TODO

- [ ] make `amazing_print` optional for production JSON logging
- [ ] port short format dev logger

# EXPERIMENTS

- [ ] there's `require 'dry/system/provider_sources/settings'` that does similar
  `dotenv` loading (see notes)

# SORBET

- does [not support](https://sorbet.org/docs/flow-sensitive#what-about-respond_to) :respond_to
- [types assertions](https://sorbet.org/docs/type-assertions)

# LOGGING

To document.

# MISC

- `awesome_print` is dead and no longer being supported. Using `amazing_print` for colored logging
