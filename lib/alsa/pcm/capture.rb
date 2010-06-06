module ALSA::PCM
  class Capture < Stream

    def native_constant
      ALSA::PCM::Native::STREAM_CAPTURE
    end

    def read
      check_handle!

      ALSA.logger.debug { "start read with #{hw_params.sample_rate}, #{hw_params.channels} channels"}

      ALSA.logger.debug { "allocate #{hw_params.buffer_size_for(buffer_frame_count)} bytes for #{buffer_frame_count} frames" }
      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(buffer_frame_count)) do |buffer|
        begin
          read_buffer buffer, buffer_frame_count
        end while yield buffer, buffer_frame_count
      end
    end

    def read_buffer(buffer, frame_count)
      check_handle!

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

  end
end
