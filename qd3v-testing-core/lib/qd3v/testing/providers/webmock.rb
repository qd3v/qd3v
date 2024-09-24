Dry::System.register_provider_source(:webmock, group: :qd3v_testing_core) do
  prepare do
    require "webmock/rspec"
  end

  start do
    target.start(:rspec)
    target[:logger].debug { "[TESTING] Loading Webmock config..." }

    register(:webmock, WebMock)
  end
end
