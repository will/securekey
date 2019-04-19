require "./app/secure_key"
require "sinatra/base"
require "json"
require "rdiscount"

class App < Sinatra::Base
  enable :inline_templates
  set :environment, ENV["RACK_ENV"]

  helpers do
    def refuse_provision(reason)
      throw(:halt, [422, {message: reason}.to_json])
    end

    def protected!
      unless authorized?
        response["WWW-Authenticate"] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        @auth.credentials == [ENV["HEROKU_USERNAME"], ENV["HEROKU_PASSWORD"]]
    end
  end

  get "/" do
    markdown File.read("./README.md"), layout_engine: :erb
  end

  # sso sign in
  get "/heroku/resources/:id" do
    halt 501
  end

  # provision
  post "/heroku/resources" do
    protected!
    params = JSON.parse(request.body.read)
    p params if ENV["DEBUG"]

    if params["plan"] == "test" && ENV["HEROKU_USERNAME"] == "securekey" # only production
      refuse_provision("test plan deprecated, please use fortnightly")
    end

    u = User.create logplex_token: params["logplex_token"],
                     callback_url: params["callback_url"],
                        heroku_id: params["heroku_id"],
                             plan: params["plan"],
                             uuid: params["uuid"]

    u.update_next_rotation_time!
    status 201
    inital_keys = [SecureKey.generate, SecureKey.generate].join(",")
    {id: u.id, value: inital_keys, config: {"KEY" => inital_keys}}.to_json
  end

  # deprovision
  delete "/heroku/resources/:id" do
    protected!
    u = User[params[:id].to_i]
    if u
      u.destroy
      "ok"
    else
      status 404
    end
  end

  # plan change
  put "/heroku/resources/:id" do
    protected!
    body = JSON.parse(request.body.read)
    u = User[params[:id].to_i]
    if u&.update(plan: body["plan"])
      "ok"
    else
      status 404
    end
  end
end

__END__

@@ layout
<!DOCTYPE>
<html>
<head><title>SecureKey</title>
<link rel="stylesheet" type="text/css" href="http://kevinburke.bitbucket.org/markdowncss/markdown.css">
</head>
<body>
<%= yield %>
</body>
</html>
