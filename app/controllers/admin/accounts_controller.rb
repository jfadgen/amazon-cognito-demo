class Admin::AccountsController < ApplicationController
  rescue_from Aws::CognitoIdentityProvider::Errors::UsernameExistsException, with: :already_exists

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @cognito_user = CognitoUser.new(@user.email)
  end

  def create
    flash[:message] = "Account for #{params[:email]} has been created."
    @user = User.create_cognito_user!(**create_params)

    redirect_to admin_accounts_path
  end

  def change_password
    user = User.find(params[:account_id])
    user.change_password!(password: params[:password])

    flash[:message] = "Account #{params[:email]} password changed successfully."

    redirect_to admin_account_path(params[:account_id])
  end

  private

  def already_exists
    flash[:message] = "Account #{params[:email]} already exists."

    redirect_to admin_accounts_path
  end

  def create_params
    {
      email: params[:email],
      password: params[:password],
      given_name: params[:given_name],
      family_name: params[:family_name],
    }
  end
end
