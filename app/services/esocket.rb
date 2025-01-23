module Esocket
  class << self
    attr_accessor :config

    def configure
      self.config ||= Esocket::Config.new

      yield(config)
    end

    def reset
      config :Configuration.new
    end
  end
end
