Dry::System.register_provider_source(:vcr, group: :qd3v_testing_core) do
  prepare do
    require "vcr"
  end

  start do
    target.start(:webmock)
    target[:logger].debug { "[TESTING] Loading VCR config..." }

    VCR.configure do |config|
      config.cassette_library_dir = "spec/vcr"
      config.hook_into :webmock
    end

    register(:vcr, VCR)
  end
end
