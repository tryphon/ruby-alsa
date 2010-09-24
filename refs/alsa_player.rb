#!/usr/bin/env ruby

# A Minimal Capture Program
# using alsa via ruby-ffi
#
# This program opens an audio interface for capture, configures it for
# stereo, 16 bit, 44.1kHz, interleaved conventional read/write
# access. Then its reads a chunk of random data from it, and exits. It
# isn't meant to be a real program.
#
# Based on C example of Paul David's tutorial : http://equalarea.com/paul/alsa-audio.html

require 'rubygems'

$: << File.expand_path("#{File.dirname(__FILE__)}/../lib")
require 'alsa'

include FFI
include ALSA::PCM::Native

ALSA.logger.level = Logger::DEBUG

alsa_device = (ARGV.first or "default")
capture_handle = MemoryPointer.new :pointer
format = Format::S16_LE

ALSA::try_to "open audio device #{alsa_device}" do
  open capture_handle, alsa_device, Stream::PLAYBACK, BLOCK
end

capture_handle = capture_handle.read_pointer

MemoryPointer.new(:pointer) do |hw_params|
  ALSA::try_to "allocate hardware parameter structure" do
    hw_params_malloc hw_params
  end
  hw_params = hw_params.read_pointer

  ALSA::try_to "initialize hardware parameter structure" do
    hw_params_any capture_handle, hw_params
  end

  ALSA::try_to "set access type" do
    hw_params_set_access capture_handle, hw_params, Access::RW_INTERLEAVED
  end

  ALSA::try_to "set sample format" do
    hw_params_set_format capture_handle, hw_params, format
  end

  ALSA::try_to "set sample rate" do
    [44100, 0].to_pointers do |rate, direction|
      hw_params_set_rate_near capture_handle, hw_params, rate, direction
    end
  end

  ALSA::try_to "set channel count" do
    hw_params_set_channels capture_handle, hw_params, 2
  end

  ALSA::try_to "set hw parameters" do
    hw_params capture_handle, hw_params
  end

  ALSA::try_to "unallocate hw_params" do
    hw_params_free hw_params
  end
end

ALSA::try_to "prepare audio interface to use" do
  prepare capture_handle
end

frame_count = 44100
MemoryPointer.new(format_size(format, frame_count) * 2) do |buffer|
  3.times do
    ALSA::try_to "write in audio interface" do
      writei(capture_handle, buffer, frame_count)
    end
  end
end

ALSA::try_to "close audio device" do
  close capture_handle
end
