require "cognito_token_verifier"
require "cognito_token_verifier/config"

CognitoTokenVerifier.configure do |config|
  config.aws_region = ENV['AWS_REGION']
  config.user_pool_id = ENV['AWS_USER_POOL_ID']
end
