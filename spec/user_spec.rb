require 'spec_helper'

describe User, 'create' do
  it 'has default heroku things' do
    User.count.should == 0
    User.create heroku_id: 'app123',
                plan: 'basic',
                callback_url: 'https://blah'
    u = User.first
    u.plan.should == 'basic'
    u.created_at.should_not be_nil
  end
end
