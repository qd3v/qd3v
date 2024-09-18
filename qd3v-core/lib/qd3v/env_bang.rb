require 'env_bang'

# This class is a central reference to all env vars. We use it inside containers via #env method
# https://github.com/jcamenisch/ENV_BANG
class ENV_BANG
  class << self
    def env
      self[:APP_ENV]
    end

    alias name env

    def prod?
      env == :production
    end

    def staging?
      env == :staging
    end

    def live?
      prod? || staging?
    end

    def dev?
      env == :development
    end

    def test?
      env == :test
    end

    def test_or_dev?
      test? || dev?
    end

    def ==(other)
      env == other.to_sym
    end

    alias to_sym env

    def to_s
      to_sym.to_s
    end
  end
end

# Updating EB config
ENV_BANG.config do |c|
  add_class :log_level do |value, options|
    if value.present?
      value.to_s.downcase.strip.to_sym
    else
      options.fetch(:default, :info)
    end
  end

  add_class :env do |value, *|
    value = begin
      value.to_s.to_sym
    rescue StandardError
      '<unparsable>'
    end

    return value if %i[production staging development test].include?(value)

    abort("Unknown environment: APP_ENV='#{value}'")
  end

  c.use :APP_ENV, class: :env
  c.use :APP_LOG_LEVEL, class: :log_level, default: :info
  c.use :APP_LOG_TO_STDOUT, class: :boolean, default: true
end
