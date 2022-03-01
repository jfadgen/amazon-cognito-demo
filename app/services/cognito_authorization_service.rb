class CognitoAuthorizationService
  REDIRECT_URI = ENV["AWS_COGNITO_REDIRECT_URI"]
  APP_CLIENT_ID = ENV["AWS_APP_CLIENT_ID"]
  APP_CLIENT_URL = ENV["AWS_APP_CLIENT_URL"]

  attr_accessor :code

  def initialize(code)
    @code = code
  end

  def call
    uri = URI.parse(APP_CLIENT_URL)
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request.set_form_data(
      grant_type: "authorization_code",
      client_id: APP_CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      code: code
    )

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response
  end
end
