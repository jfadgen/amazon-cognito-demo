class Cognito

  def initialize
    @aws_region = ENV['AWS_REGION']
    @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    @secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    @user_pool_id = ENV['AWS_USER_POOL_ID']
    @app_client_id = ENV["AWS_APP_CLIENT_ID"]
  end

  def client
    @client ||= Aws::CognitoIdentityProvider::Client.new(
      region: @aws_region,
      access_key_id: @aws_access_key_id,
      secret_access_key: @secret_access_key)
  end

  def admit_reset_user_password(username)
    client.admin_reset_user_password({
      user_pool_id: @user_pool_id,
      username: username,
    })
  end

  def admin_get_user(username)
    client.admin_get_user({
      user_pool_id: @user_pool_id,
      username: username,
    })
  end

  def list_users
    client.list_users({
      user_pool_id: @user_pool_id,
    })
  end

  def authenticate(username:, password:)
    user_object = {
      USERNAME: username,
      PASSWORD: password,
    }
    auth_object = {
      user_pool_id: @user_pool_id,
      client_id: @app_client_id,
      auth_flow: "ADMIN_NO_SRP_AUTH",
      auth_parameters: user_object,
    }
    client.admin_initiate_auth(auth_object)
  end

  def refresh_token(refresh_token:)
    user_object = {
      REFRESH_TOKEN: refresh_token,
    }
    auth_object = {
      user_pool_id: @user_pool_id,
      client_id: @app_client_id,
      auth_flow: "REFRESH_TOKEN_AUTH",
      auth_parameters: user_object,
    }
    client.admin_initiate_auth(auth_object)
  end

  def create_user(username:, password:, user_attributes: {})
    # Cognito.new.create_user(username: 'taco', password: 'P@ssword1', user_attributes: [{name: "email", value: "test@good.com"}])
    auth_object = {
      user_pool_id: @user_pool_id,
      username: username,
      temporary_password: password,
      user_attributes: user_attributes,
      message_action: "SUPPRESS",
      desired_delivery_mediums: ["EMAIL"],
    }
    client.admin_create_user(auth_object)
  end

  def set_password(username:, password:, permanent: false)
    resp = client.admin_set_user_password({
      user_pool_id: @user_pool_id,
      username: username,
      password: password,
      permanent: permanent,
    })
  end
end
