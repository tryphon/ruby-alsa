require 'spec_helper'

describe ALSA::PCM::Stream do

  describe "native_constant" do
    
    it "should be ALSA::PCM::Native::STREAM_CAPTURE for Capture" do
      ALSA::PCM::Capture.new.native_constant.should == ALSA::PCM::Native::STREAM_CAPTURE
    end

    it "should be ALSA::PCM::Native::STREAM_PLAYBACK for Playback" do
      ALSA::PCM::Playback.new.native_constant.should == ALSA::PCM::Native::STREAM_PLAYBACK
    end

  end

end
