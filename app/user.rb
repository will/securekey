require 'rest_client'
require 'json'

class User < Sequel::Model
  DAILY = 24*60*60
  WEEKLY = DAILY * 7
  FORTNIGHTLY = WEEKLY * 2

  def_dataset_method :rotateable do
    with_sql(
      "SELECT * FROM users WHERE
        (plan='daily' AND rotated_at <= ?) OR
        (plan='weekly' AND rotated_at <= ?) OR
        (plan='fortnightly' AND rotated_at <= ?)",
      Time.now - DAILY,
      Time.now - WEEKLY,
      Time.now - FORTNIGHTLY
    )
  end

  def rotate_keys!
    write_keys(SecureKey.generate, get_current_key)
  end

  def write_keys(new_key, old_key)
   keys = {"SECURE_KEY" => new_key, "SECURE_KEY_OLD" => old_key}
   RestClient.put(heroku_url, {
        :config => keys
      }.to_json,
      :content_type => :json,
      :accept       => :json
    )
    update(:rotated_at => Time.now)
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
end
