require 'spec_helper'

describe ALSA::PCM::Native do

  it "should provide the Stream::CAPTURE constant" do
    ALSA::PCM::Native::Stream::CAPTURE.should == 1
  end
  
end
