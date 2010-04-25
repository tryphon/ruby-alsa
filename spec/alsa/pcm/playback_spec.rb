require 'spec_helper'

describe ALSA::PCM::Playback do

  let(:device) { "default" }

  def pending_if_no_device
    pending("requires a real alsa device") unless File.exists?("/proc/asound")
  end

  describe "#write_buffer" do

    let(:playback) { ALSA::PCM::Playback.new }

    it "should raise an error when playback isn't opened" do
      lambda { playback.write_buffer(nil, 0) }.should raise_error
    end
    
    it "should play given samples (buffer and frame count)" do
      pending_if_no_device

      FFI::MemoryPointer.new(:char, 1024) do |buffer|
        playback.open(device) do |playback|
          playback.write_buffer buffer, 100
        end
      end
    end

  end

end
