class AccountsController < ApplicationController
  class SessionExpiredError < StandardError; end

  rescue_from Aws::CognitoIdentityProvider::Errors::NotAuthorizedException, with: :deny_access
  rescue_from SessionExpiredError, with: :session_expired

  before_action :current_user, only: [:index, :welcome]
  before_action :refresh_session, only: [:welcome]

  def create
    unless valid_submission?
      @message = "Please enter both a username and password."
      render :index, status: :unauthorized
    else
      user = User.find_by(email: params[:email])

      if user.nil?
        @message = "Unknown user."
        render :index, status: :unauthorized
      else
        user.authenticate!(auth_params)
        session[:current_user] = user

        redirect_to welcome_accounts_path
      end
    end
  end

  def index
    Rails.logger.info "~ index"
  end

  def welcome
    Rails.logger.info "~ welcome"
  end

  def sign_out
    @message = "You have been signed out."
    session[:current_user] = nil
    render :index, status: :unauthorized
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

  def session_expired
    @message = "Session has expired."
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

  def refresh_session
    raise SessionExpiredError unless current_user&.active_session.present?

    current_user.active_session.refresh_session
  end
end
