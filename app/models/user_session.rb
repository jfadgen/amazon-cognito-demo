class UserSession < ApplicationRecord
  belongs_to :user

  def expired?
    decoded_id_token.expired?
  end

  def expiration
    decoded_id_token.decoded_token["exp"]
  end

  def refresh_session
    response = Cognito.new.refresh_token(refresh_token: refresh_token)
    update!(access_token: response.authentication_result.access_token, id_token: response.authentication_result.id_token)
  end

  private

  def decoded_id_token
    @decoded_id_token ||= CognitoTokenVerifier::Token.new(id_token)
  end

  def decoded_access_token
    @decoded_access_token ||= CognitoTokenVerifier::Token.new(access_token)
  end
end
