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

describe User, ".rotateable" do
  def subject
    #puts User.rotateable.sql
    User.rotateable.all.map(&:id)
  end

  before do
    @d1 = User.create(plan: 'daily',       rotated_at: Time.new(2011,2,1) ).id
    @d2 = User.create(plan: 'daily',       rotated_at: Time.new(2011,2,2) ).id
    @w1 = User.create(plan: 'weekly',      rotated_at: Time.new(2011,2,1) ).id
    @w2 = User.create(plan: 'weekly',      rotated_at: Time.new(2011,2,8) ).id
    @f1 = User.create(plan: 'fortnightly', rotated_at: Time.new(2011,2,1) ).id
    @f2 = User.create(plan: 'fortnightly', rotated_at: Time.new(2011,2,15)).id
  end

  def on_day(day, *users)
    Timecop.freeze(2011,2,day)
    subject.should == users
  end

  after { Timecop.return }

  it 'finds the right ones' do
     Timecop.freeze(1999,7,14)
     subject.should =~ []

     on_day  1
     on_day  2, @d1
     on_day  3, @d1, @d2
     on_day  4, @d1, @d2
     on_day  5, @d1, @d2
     on_day  6, @d1, @d2
     on_day  7, @d1, @d2
     on_day  8, @d1, @d2, @w1
     on_day  9, @d1, @d2, @w1
     on_day 10, @d1, @d2, @w1
     on_day 11, @d1, @d2, @w1
     on_day 12, @d1, @d2, @w1
     on_day 13, @d1, @d2, @w1
     on_day 14, @d1, @d2, @w1
     on_day 15, @d1, @d2, @w1, @w2, @f1
     on_day 16, @d1, @d2, @w1, @w2, @f1
     on_day 17, @d1, @d2, @w1, @w2, @f1
     on_day 18, @d1, @d2, @w1, @w2, @f1
     on_day 19, @d1, @d2, @w1, @w2, @f1
     on_day 20, @d1, @d2, @w1, @w2, @f1
     on_day 21, @d1, @d2, @w1, @w2, @f1
     on_day 22, @d1, @d2, @w1, @w2, @f1
     on_day 23, @d1, @d2, @w1, @w2, @f1
     on_day 24, @d1, @d2, @w1, @w2, @f1
     on_day 25, @d1, @d2, @w1, @w2, @f1
     on_day 25, @d1, @d2, @w1, @w2, @f1
     on_day 26, @d1, @d2, @w1, @w2, @f1
     on_day 27, @d1, @d2, @w1, @w2, @f1
     on_day 28, @d1, @d2, @w1, @w2, @f1
     on_day 29, @d1, @d2, @w1, @w2, @f1, @f2
  end
end

describe User, '#rotate_keys!' do
  let(:u) { User.new callback_url: 'https://callback.url/path' }
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

  it 'sets and saves rotated_at' do
    u.rotated_at.should be_nil
    u.rotate_keys!
    u.reload
    u.rotated_at.should be_within(1).of(Time.now)
  end
end
