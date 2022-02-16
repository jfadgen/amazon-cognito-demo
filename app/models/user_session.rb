class UserSession < ApplicationRecord
  belongs_to :user

  def expired?
    decoded_id_token.expired?
  end

  private

  def decoded_id_token
    @decoded_id_token ||= CognitoTokenVerifier::Token.new(id_token)
  end

  def decoded_access_token
    @decoded_access_token ||= CognitoTokenVerifier::Token.new(access_token)
  end
end
