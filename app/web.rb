require './app/secure_key'
require 'sinatra/base'

class App < Sinatra::Base
  set :views, './views'
  use Rack::Session::Cookie, secret: ENV['SSO_SALT']

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD']]
    end
  end

  get "/" do
    haml :index
  end

  # sso sign in
  get "/heroku/resources/:id" do
    pre_token = params[:id] + ':' + ENV['SSO_SALT'] + ':' + params[:timestamp]
    token = Digest::SHA1.hexdigest(pre_token).to_s
    halt 403 if token != params[:token]
    halt 403 if params[:timestamp].to_i < (Time.now - 2*60).to_i

    account = true #User.get(params[:id])
    halt 404 unless account

    session[:heroku_sso] = params['nav-data']
    response.set_cookie('heroku-nav-data', value: params['nav-data'])
    haml :index
  end

  # provision
  post '/heroku/resources' do
    protected!
    params = JSON.parse(request.body.read)
    u = User.create logplex_token: params['logplex_token'],
                     callback_url: params['callback_url'],
                        heroku_id: params['heroku_id'],
                             plan: params['plan']

    status 201
    {id: u.id, config: {'SECURE_KEY' => SecureKey.generate, 'SECURE_KEY_OLD' => ''}}.to_json
  end

  # deprovision
  delete '/heroku/resources/:id' do
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
  put '/heroku/resources/:id' do
    protected!
    "ok"
  end
end
