require 'spec_helper'

describe ALSA::PCM::Capture do

  let(:device) { "default" }

  def pending_if_no_device
    pending("requires a real alsa device") unless File.exists?("/proc/asound")
  end

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

  describe "#open" do

    let(:capture) { ALSA::PCM::Capture.new }

    after(:each) do
      capture.close if capture.opened?
    end

    it "should initialize the native handle" do
      pending_if_no_device

      capture.open(device)
      capture.handle.should_not be_nil
    end

    context "when a block is given" do

      it "should yield the block with itself" do
        pending_if_no_device

        capture.open(device) do |given_capture|
          given_capture.should == capture
        end
      end

      it "should close the capture after block" do
        pending_if_no_device

        capture.open(device) {}
        capture.should_not be_opened
      end
                                      
    end

  end

  describe "#read" do

    let(:capture) { ALSA::PCM::Capture.new }
    
    it "should raise an error when cature isn't opened" do
      lambda { capture.read }.should raise_error
    end

    it "should yield with read samples (buffer and frame count)" do
      pending_if_no_device

      capture.open(device) do |capture|
        capture.read do |buffer, frame_count|
          buffer.size.should == capture.hw_params.buffer_size_for(frame_count)
          false
        end
      end
    end

    it "should stop reading when block returns false" do
      pending_if_no_device

      read_count = 0
      capture.open(device) do |capture|
        capture.read do |buffer, frame_count|
          read_count += 1
          read_count < 3
        end
      end
      read_count.should == 3
    end

  end

end
