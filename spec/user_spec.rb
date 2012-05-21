require 'spec_helper'

describe User, 'create' do
  it 'has default heroku things' do
    User.count.should == 0
    User.create heroku_id: 'app123',
                plan: 'daily',
                callback_url: 'https://blah',
                logplex_token: 't.239d9f'
    u = User.first
    u.plan.should == 'daily'
    u.created_at.should_not be_nil
  end

  it { }
  it { }
  it { }
  it { }
  it { }
end

describe User, ".rotatable" do
  def subject
    #puts User.rotatable.sql
    User.rotatable.all.map(&:id)
  end

  before do
    @yes1 = User.create(plan: 'daily',       next_rotation: Time.now - 100).id
    @yes2 = User.create(plan: 'daily',       next_rotation: nil           ).id
    @yes3 = User.create(plan: 'weekly',      next_rotation: Time.now - 200).id
    @no1  = User.create(plan: 'weekly',      next_rotation: Time.now + 100).id
    @no2  = User.create(plan: 'fortnightly', next_rotation: Time.now + 300).id
    @no3  = User.create(plan: 'fortnightly', next_rotation: Time.now + 900).id
  end

  it 'includes the users that need a rotation right now' do
    subject.should =~ [@yes1, @yes2, @yes3]
  end
end

describe User, '#rotate_keys!' do
  let(:u) { User.new callback_url: 'https://callback.url/path', :next_rotation => Time.now }
  let(:url) { "https://huser:hpass@callback.url/path" }

  before do
    ENV['HEROKU_USERNAME'] = 'huser'
    ENV['HEROKU_PASSWORD'] = 'hpass'
    body = {"config" => {"SECURE_KEY" => 'abc123'}}.to_json
    stub_request(:get, url).to_return(body: body)

    SecureKey.stub(:generate).and_return('new789')
    body = {'config' => {"SECURE_KEY" => 'new789', "SECURE_KEY_OLD" => 'abc123'}}.to_json
    @stubreq = stub_request(:put, url).with(body: body)
  end

  it 'sets a new key and rotates the old one' do
    SecureKey.should_receive(:generate).and_return('new789')
    u.rotate_keys!
    @stubreq.should have_been_requested
  end

  def plan_time(plan_name, time)
    u.plan = plan_name
    future_time = Time.now + time
    u.next_rotation.should_not be_within(1).of(future_time)
    u.rotate_keys!
    u.next_rotation.should be_within(1).of(future_time)
  end

  it { plan_time 'daily',       60*60*24 }
  it { plan_time 'weekly',      60*60*24*7 }
  it { plan_time 'fortnightly', 60*60*24*14 }
  it { plan_time 'monthly',     60*60*24*28 }
end
