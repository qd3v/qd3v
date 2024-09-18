module Qd3v
  module Core
    Container.register_provider(:config) do
      start do
        register(:config, Config.config)
      end
    end
  end
end
