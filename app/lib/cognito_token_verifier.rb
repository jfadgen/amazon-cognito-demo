# Credit: https://github.com/CodingAnarchy/cognito_token_verifier
# MIT License
module CognitoTokenVerifier
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Config.new
  end

  def self.reset
    @config = Config.new
  end

  def self.configure
    yield(config)
  end
end
