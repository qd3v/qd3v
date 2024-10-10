require 'env_bang'

# This class is a central reference to all env vars. We use it inside containers via #env method
# https://github.com/jcamenisch/ENV_BANG
# TODO: Use define_method + YARD for predicate methods once API stabilized
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

    # TODO: experimental. DRY and extend this approach to the rest of methods
    def live?
      condition = prod? || staging?

      return condition unless block_given?

      yield if condition
    end

    def dev?
      condition = env == :development

      return condition unless block_given?

      yield if condition
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

    def environments
      @environments ||= %i[production staging development test]
    end

    attr_writer :environments
  end
end
