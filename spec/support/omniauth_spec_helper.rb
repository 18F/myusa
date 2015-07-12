module OmniAuthSpecHelper
  # http://stackoverflow.com/questions/19483367
  def self.silence_omniauth
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new('/dev/null')
    yield
  ensure
    OmniAuth.config.logger = previous_logger
  end
end
