class User < ApplicationRecord
  has_many :user_sessions

  delegate :full_name, to: :active_session

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

  def change_password!(password:)
    user = Cognito.new.set_password(username: email, password: password, permanent: true)
  end

  def self.create_cognito_user!(email:, password:, given_name:, family_name:)
    find_or_create_by(email: email)

    user_attributes = [
      { name: "given_name", value: given_name },
      { name: "family_name", value: family_name },
    ]
    Cognito.new.create_user(username: email, password: password, user_attributes: user_attributes)

    # This is temporary until this app is configured to handle password resets.
    Cognito.new.set_password(username: email, password: password, permanent: true)
  end
end
