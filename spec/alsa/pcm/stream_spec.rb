require 'spec_helper'

describe ALSA::PCM::Stream do

  describe "native_constant" do
    
    it "should be ALSA::PCM::Native::Stream::CAPTURE for Capture" do
      ALSA::PCM::Capture.new.native_constant.should == ALSA::PCM::Native::Stream::CAPTURE
    end

    it "should be ALSA::PCM::Native::Stream::PLAYBACK for Playback" do
      ALSA::PCM::Playback.new.native_constant.should == ALSA::PCM::Native::Stream::PLAYBACK
    end

  end

end
