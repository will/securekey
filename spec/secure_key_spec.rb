require 'spec_helper'

describe SecureKey, ".generate" do
  it 'makes different keys' do
    SecureKey.generate.should_not == SecureKey.generate
  end

  it 'generates hex-encodable keys reliably 64 characters in length' do
    100.times do
      SecureKey.generate.length.should == 64
    end
  end
end
