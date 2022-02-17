class User < ApplicationRecord
  has_many :user_sessions

  def authenticate!(auth_params)
    cognito_authentication = Cognito.new.authenticate(**auth_params)

    user_sessions.create!(
      access_token: cognito_authentication.authentication_result.access_token,
      id_token: cognito_authentication.authentication_result.id_token,
      refresh_token: cognito_authentication.authentication_result.refresh_token,
    )
  end

  def active_session
    @active_session ||= user_sessions.last unless user_sessions.last.expired?
  end
end
