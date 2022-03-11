class AuthController < ApplicationController
  def index
    if params["code"].present?
      response = CognitoAuthorizationService.new(params["code"]).call

      if response.code == "200"
        user_session = create_user_session(response)

        Rails.logger.info "Successfully authenticated."
        session[:current_user] = user_session.user
        redirect_to welcome_accounts_path
      else
        Rails.logger.info "Access Denied."
        redirect_to unauthorized_accounts_path
      end
    else
      Rails.logger.info "Access Denied: Missing code."
      redirect_to unauthorized_accounts_path
    end
  end

  private

  def create_user_session(response)
    response_json = JSON.parse(response.body)
    user_session = UserSession.new(
      id_token: response_json["id_token"],
      access_token: response_json["access_token"],
      refresh_token: response_json["refresh_token"],
    )
    user = User.find_by(email: user_session.email)
    user_session.update(user_id: user.id)
    user_session
  end
end
