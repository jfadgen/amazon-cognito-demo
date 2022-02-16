class AccountsController < ApplicationController
  rescue_from Aws::CognitoIdentityProvider::Errors::NotAuthorizedException, with: :deny_access

  def index
    unless valid_submission?
      @message = "Please enter both a username and password."
    else
      result = Cognito.new.authenticate(**auth_params)
      @user = User.find_or_create_by(email: params[:email])
      @user.user_sessions.create!(
        access_token: result.authentication_result.access_token,
        id_token: result.authentication_result.id_token,
        refresh_token: result.authentication_result.refresh_token,
      )
      @result = result

      render action: "show" , status: :accepted
    end
  end

  def show
    Rails.logger.info "~ show"
  end

  private

  def auth_params
    {
      username: params[:email],
      password: params[:password],
    }
  end

  def deny_access
    @message = "Access denied."
    render :index, status: :unauthorized
  end

  def valid_submission?
    params[:email].present? && params[:password].present?
  end
end
