class AuthController < ApplicationController
  def index
    if params["code"].present?
      response = CognitoAuthorizationService.new(params["code"]).call

      if response.code == "200"
        user_session = create_user_session(response)
        render json: { response: "good: user_session: #{user_session.id}" }
      else
        render json: { response: "Access Denied"}
      end
    else
      render json: { response: "Missing Code"}
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
    user = User.find_by(email: user_session.decoded_email)
    user_session.update(user_id: user.id)
    user_session
  end
end
