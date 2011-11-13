require 'spec_helper'

describe SecureKey, ".generate" do
  it 'makes different keys' do
    SecureKey.generate.should_not == SecureKey.generate
  end
end
