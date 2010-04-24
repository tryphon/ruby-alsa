require 'spec_helper'

describe ALSA::Native do

  describe ".error_code?" do
    
    it "should return true when given value is negative" do
      ALSA::Native.error_code?(-1).should be_true
    end

    it "should return false when given value is zero" do
      ALSA::Native.error_code?(0).should be_false
    end

    it "should return false when given value is positive" do
      ALSA::Native.error_code?(1).should be_false
    end

  end

  describe ".strerror" do
    
    it "should invoke snd_strerror function" do
      ALSA::Native.strerror(500000).should == "Sound protocol is not compatible"
    end

  end


end
