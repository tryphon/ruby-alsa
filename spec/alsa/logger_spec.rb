require 'spec_helper'

describe ALSA, "logger" do
  
  it "should have a default value" do
    ALSA.logger.should_not be_nil
  end

end
