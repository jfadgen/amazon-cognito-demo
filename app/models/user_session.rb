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

  def email
    decoded_id_token.decoded_token["email"]
  end

  def given_name
    decoded_id_token.decoded_token["given_name"]
  end

  def family_name
    decoded_id_token.decoded_token["family_name"]
  end

  def full_name
    [given_name, family_name].join(' ')
  end

  private

  def decoded_id_token
    @decoded_id_token ||= CognitoTokenVerifier::Token.new(id_token)
  end

  def decoded_access_token
    @decoded_access_token ||= CognitoTokenVerifier::Token.new(access_token)
  end
end
