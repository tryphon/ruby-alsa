require 'spec_helper'

describe ALSA::PCM::Capture do

  describe ".open" do

    let(:capture) { stub :open => true }
    let(:hardware_attributes) { Hash.new :dummy => true }

    before(:each) do
      ALSA::PCM::Capture.stub :new => capture
    end
    
    it "should create a Capture instance" do
      ALSA::PCM::Capture.should_receive(:new).and_return(capture)
      ALSA::PCM::Capture.open(:device)
    end

    it "should create the Capture instance with given arguments" do
      capture.should_receive(:open).with(:device, hardware_attributes)
      ALSA::PCM::Capture.open(:device, hardware_attributes)
    end

  end

end
