require 'spec_helper'

describe ALSA, "try_to" do

  it "should log in debug the given message" do
    ALSA.logger.should_receive(:debug)
    ALSA::try_to("dummy") {}
  end

  it "should execute the given block and return its value" do
    ALSA::try_to("dummy") { 0 }.should == 0
  end

  context "when block returns a negative value" do

    it "should raise an error (with strerror of error code)" do
      ALSA::Native.stub!(:strerror).and_return("error string")
      lambda { ALSA::try_to("dummy") { -1 } }.should raise_error("cannot dummy (error string)")
    end

  end

end
