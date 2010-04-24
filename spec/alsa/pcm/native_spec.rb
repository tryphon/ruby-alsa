require 'spec_helper'

describe ALSA::PCM::Native do

  it "should provide the STREAM_CAPTURE constant" do
    ALSA::PCM::Native::STREAM_CAPTURE.should == 1
  end
  
end
