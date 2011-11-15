require 'spec_helper'

describe User, 'create' do
  it 'has default heroku things' do
    User.count.should == 0
    User.create heroku_id: 'app123',
                plan: 'basic',
                callback_url: 'https://blah',
                logplex_token: 't.239d9f'
    u = User.first
    u.plan.should == 'basic'
    u.created_at.should_not be_nil
  end
end

describe User, '#rotate_keys!' do
  let(:u) { User.new callback_url: 'https://callback.url/path' }
  let(:url) { "https://huser:hpass@callback.url/path" }

  before do
    ENV['HEROKU_USERNAME'] = 'huser'
    ENV['HEROKU_PASSWORD'] = 'hpass'
  end

  it 'sets a new key and rotates the old one' do
    body = {"config" => {"SECURE_KEY" => 'abc123'}}.to_json
    stub_request(:get, url).to_return(body: body)

    SecureKey.should_receive(:generate).and_return('new789')
    body = {'config' => {"SECURE_KEY" => 'new789', "SECURE_KEY_OLD" => 'abc123'}}.to_json
    stubreq = stub_request(:put, url).with(body: body)

    u.rotate_keys!

    stubreq.should have_been_requested
  end

end
