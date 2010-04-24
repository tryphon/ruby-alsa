module ALSA::PCM
  class Capture

    attr_accessor :handle

    def self.open(device, hardware_attributes = {}, &block)
      Capture.new.open(device, hardware_attributes, &block)
    end

    def open(device, hardware_attributes = {}, &block)
      capture_handle = FFI::MemoryPointer.new :pointer
      ALSA::try_to "open audio device #{device}" do
        ALSA::PCM::Native::open capture_handle, device, ALSA::PCM::Native::STREAM_CAPTURE, ALSA::PCM::Native::BLOCK
      end
      self.handle = capture_handle.read_pointer

      self.hardware_parameters=hardware_attributes

      if block_given?
        begin
          yield self 
        ensure
          self.close
        end
      end
    end

    def change_hardware_parameters
      hw_params = HwParameters.new(self).default_for_device

      begin
        yield hw_params

        ALSA::try_to "set hw parameters" do
          ALSA::PCM::Native::hw_params self.handle, hw_params.handle
        end
      ensure
        hw_params.free
      end
    end

    def hardware_parameters
      HwParameters.new(self).current_for_device
    end
    alias_method :hw_params, :hardware_parameters

    def hardware_parameters=(attributes= {})
      attributes = {:access => :rw_interleaved}.update(attributes)
      change_hardware_parameters do |hw_params|
        hw_params.update_attributes(attributes)
      end
    end

    def read
      ALSA.logger.debug { "start read with #{hw_params.sample_rate}, #{hw_params.channels} channels"}

      # use an 500ms buffer
      frame_count = hw_params.sample_rate / 2
      ALSA.logger.debug { "allocate #{hw_params.buffer_size_for(frame_count)} bytes for #{frame_count} frames" }
      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(frame_count)) do |buffer|
        begin
          read_buffer buffer, frame_count
        end while yield buffer, frame_count
      end
    end

    def read_buffer(buffer, frame_count)
      read_count = ALSA::try_to "read from audio interface" do
        response = ALSA::PCM::Native::readi(self.handle, buffer, frame_count)
        if ALSA::Native::error_code?(response)
          ALSA.logger.warn { "try to recover '#{ALSA::Native::strerror(response)}' on read"}
          ALSA::PCM::Native::pcm_recover(self.handle, response, 1)
        else
          response
        end
      end

      missing_frame_count = frame_count - read_count
      if missing_frame_count > 0
        ALSA.logger.debug { "re-read missing frame count: #{missing_frame_count}"}
        read_buffer_size = hw_params.buffer_size_for(read_count)
        # buffer[read_buffer_size] doesn't return a MemoryPointer
        read_buffer(buffer + read_buffer_size, missing_frame_count)
      end
    end

    def close
      ALSA::try_to "close audio device" do
        ALSA::PCM::Native::close self.handle
      end
    end


  end
end
