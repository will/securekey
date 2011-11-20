require 'rest_client'
require 'json'

class User < Sequel::Model
  def_dataset_method :rotatable do
    filter{ next_rotation < Time.now }.or(:next_rotation => nil)
  end

  def rotate_keys!
    write_keys(SecureKey.generate, get_current_key)
    update_next_rotation_time!
  end

  def write_keys(new_key, old_key)
   keys = {"SECURE_KEY" => new_key, "SECURE_KEY_OLD" => old_key}
   RestClient.put(heroku_url, {
        :config => keys
      }.to_json,
      :content_type => :json,
      :accept       => :json
    )
  end

  def get_current_key
    response = JSON.parse(RestClient.get(heroku_url))
    response['config']['SECURE_KEY']
  end

  def heroku_url
    url = URI.parse(callback_url)
    url.user = ENV["HEROKU_USERNAME"]
    url.password = ENV["HEROKU_PASSWORD"]
    return url.to_s
  end

  def update_next_rotation_time!
    next_time = Time.now + case plan
    when 'daily'       then 60*60*24
    when 'weekly'      then 60*60*24*7
    when 'fortnightly' then 60*60*24*14
    else 60*60*24*28
    end
    update :next_rotation => next_time
  end
end
