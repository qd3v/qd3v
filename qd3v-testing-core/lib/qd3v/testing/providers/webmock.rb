Dry::System.register_provider_source(:webmock, group: :qd3v_testing_core) do
  prepare do
    require "webmock/rspec"
  end

  start do
    target.start(:logger)

    logger = target[:logger]
    logger.debug { "[TESTING] Loading Webmock config..." }

    target.start(:rspec)

    register(:webmock_loaded, true)
  end
end
