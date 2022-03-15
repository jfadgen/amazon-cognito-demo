class AccountsController < ApplicationController
  class SessionExpiredError < StandardError; end

  rescue_from Aws::CognitoIdentityProvider::Errors::NotAuthorizedException, with: :deny_access
  rescue_from SessionExpiredError, with: :session_expired

  before_action :current_user, only: [:index, :welcome]
  before_action :refresh_session!, only: [:welcome]

  def create
    unless valid_submission?
      flash[:info] = "Please enter both a username and password."
      render :index, status: :unauthorized
    else
      user = User.find_by(email: params[:email])

      if user.nil?
        flash[:info] = "Unknown user."
        render :index, status: :unauthorized
      else
        user.authenticate!(auth_params)
        session[:current_user] = user

        Rails.logger.info "\n ~~ Redirect URL: #{params[:redirect_url]}"
        if params[:redirect_url].present?
          redirect_to redirect_url, allow_other_host: true
        else
          redirect_to welcome_accounts_path
        end
      end
    end
  end

  def index
    Rails.logger.info "~ index"

    if refresh_session && current_user&.active_session
      render "continue_session"
    end
  end

  def welcome
    Rails.logger.info "~ welcome"
  end

  def sign_out
    session[:current_user] = nil
    # TODO: Signout of cognito.
    redirect_to accounts_path, info: "You have been signed out."
  end

  def reset_password
    Rails.logger.info "~ reset_password"
  end

  def send_confirmation_code
    Rails.logger.info "~ send_confirmation_code"
    Cognito.new.forgot_password(username: params[:email])

    render "confirm_reset_password"
  end

  def confirm_reset_password
    Rails.logger.info "~ confirm_reset_password"
    payload = {
      username: params[:email],
      password: params[:password],
      confirmation_code: params[:confirmation_code],
    }
    Cognito.new.confirm_forgot_password(**payload)

    redirect_to accounts_path, info: "Please login with your new password."
  rescue Aws::CognitoIdentityProvider::Errors::InvalidParameterException => error
    flash[:info] = "Invalid Confirmation Code for the email provided."
  rescue Aws::CognitoIdentityProvider::Errors::InvalidPasswordException => error
    flash[:info] = "Invalid password."
  end

  private

  def auth_params
    {
      username: params[:email],
      password: params[:password],
    }
  end

  def deny_access
    flash[:info] = "Access denied."
    render :index, status: :unauthorized
  end

  def session_expired
    flash[:info] = "Session has expired." if session[:current_user].present?
    render :index, status: :unauthorized
  end

  def valid_submission?
    params[:email].present? && params[:password].present?
  end

  def authenticated_user?
    current_user.active_session.present?
  end

  def current_user
    return unless session[:current_user]
    @current_user ||= User.find_by(email: session[:current_user]["email"])
  end

  def refresh_session!
    raise SessionExpiredError unless current_user&.active_session.present?

    refresh_session
  end

  def refresh_session
    current_user.active_session.refresh_session if current_user&.active_session.present?
  end

  def redirect_url
    redirect_url = URI.parse(params[:redirect_url])
    new_redirect_url = URI.decode_www_form(String(redirect_url.query)) << ["access_key", "temp_access_key"]
    redirect_url.query = URI.encode_www_form(new_redirect_url)
    redirect_url.to_s
  end
end
