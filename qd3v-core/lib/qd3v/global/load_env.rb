# auto_register: false

# ^^^ it seems this is ignored by ZW (ZEITWERK_DEBUG=1) ^^^

require 'dotenv'

#
# VALIDATING MAIN `APP_ENV` VAR
#

# Scoping variables
proc do
  env = ENV.fetch('APP_ENV', 'development').to_s.strip

  raise("[ENV]: Unknown 'APP_ENV' environment var value: '#{env}'") unless %w[
    production staging development test
  ].include?(env)

  # APP_ENV has priority over RAILS_ENV
  # Ensure env var updated for development case.
  ENV['APP_ENV'] = ENV['RAILS_ENV'] = env

  $stderr.puts("[ENVIRONMENT: #{env}]}".upcase)

  # Switch to "production" mode (skips few dev-only middleware, like error rendering)
  # Rack use String type -> `Rack::Server.middleware["development"] = []`
  ENV['RACK_ENV'] = 'deployment' unless %w[development test].include?(env)

  #
  # LOADING ENV FILES FOR DEV/TEST ONLY
  #

  if %w[development test].include?(env)

    env_files     = %W[.env .env.#{env} .env.local .env.#{env}.local]
    env_files_abs = env_files.map { File.join(Dir.pwd, it) }

    $stderr.puts("[ENV] Loading env files: #{env_files}")

    # NOTE: Reverse order is required here for some reason
    Dotenv.load(*env_files_abs.reverse!)
  end

  # Fixing Rails expected env var
  ENV['DATABASE_URL'] = ENV['PG_URI'] if ENV['PG_URI']
end.call
