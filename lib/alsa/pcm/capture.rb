module ALSA::PCM
  class Capture < Stream

    def native_constant
      ALSA::PCM::Native::Stream::CAPTURE
    end

    def read
      check_handle!

      ALSA.logger.debug { "start read with #{hw_params.inspect}"}

      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(buffer_frame_count)) do |buffer|
        begin
          read_buffer buffer, buffer_frame_count
        end while yield buffer, buffer_frame_count
      end
    end

    def read_in_background(&block)
      check_handle!

      async_handler = FFI::MemoryPointer.new(:pointer)
      buffer = FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(buffer_frame_count))

      started = false

      capture_callback = Proc.new do |async_handler|
        if started
          frame_to_read = buffer_frame_count
          read_buffer buffer, frame_to_read
          yield buffer, frame_to_read
        end
      end

      ALSA::try_to "add pcm handler" do
        ALSA::Native::async_add_pcm_handler(async_handler, handle, capture_callback, nil)
      end

      ALSA::try_to "start capture" do
        ALSA::PCM::Native::start(handle)
      end

      hole_frame_count = ALSA::try_to "read available space" do
        ALSA::PCM::Native::avail_update(self.handle)
      end
      ALSA.logger.debug { "read synchronously #{hole_frame_count} frames"}
      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(hole_frame_count)) do |hole|
        ALSA::PCM::Native::readi self.handle, hole, hole_frame_count
      end

      started = true
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

      ALSA.logger.debug { "read frame count: #{read_count}/#{frame_count}"}

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
