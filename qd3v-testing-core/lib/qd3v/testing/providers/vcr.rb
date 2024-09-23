Dry::System.register_provider_source(:vcr, group: :qd3v_testing_core) do
  prepare do
    require "vcr"
  end

  start do
    target.start(:logger)

    logger = target[:logger]
    logger.debug { "[TESTING] Loading VCR config..." }

    target.start(:rspec)
    target.start(:webmock)

    VCR.configure do |config|
      config.cassette_library_dir = "spec/vcr"
      config.hook_into :webmock
    end

    register(:vcr_loaded, true)
  end
end
