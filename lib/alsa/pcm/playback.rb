module ALSA::PCM
  class Playback < Stream

    def native_constant
      ALSA::PCM::Native::Stream::PLAYBACK
    end

    def write_buffer(buffer, frame_count)
      check_handle!
      
      write_count = ALSA::try_to "write in audio interface" do
        response = ALSA::PCM::Native::writei(self.handle, buffer, frame_count)
        if ALSA::Native::error_code?(response)
          ALSA.logger.warn { "try to recover '#{ALSA::Native::strerror(response)}' on write"}
          ALSA::PCM::Native::pcm_recover(self.handle, response, 1)
        else
          response
        end
      end

      ALSA.logger.debug { "write frame count: #{write_count}/#{frame_count}"}

      missing_frame_count = frame_count - write_count
      if missing_frame_count > 0
        ALSA.logger.debug { "missing wroted frame count: #{missing_frame_count}"}
      end
    end

    def write_in_background(&block)
      check_handle!

      async_handler = FFI::MemoryPointer.new(:pointer)
      buffer = FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(buffer_frame_count))

      started = false

      playback_callback = Proc.new do |async_handler|
        if started
          audio_content = yield(buffer.size)
          buffer.write_string audio_content
        
          read_frame_count = 
            if audio_content.size == buffer.size 
              buffer_frame_count
            else
              hw_params.frame_count_for(audio_content.size)
            end
          
          write_buffer buffer, read_frame_count
        end
      end

      ALSA::try_to "add pcm handler" do
        ALSA::Native::async_add_pcm_handler(async_handler, handle, playback_callback, nil)
      end

      ALSA::try_to "start playback" do
        ALSA::PCM::Native::start(handle)
      end

      silent_frame_count = ALSA::try_to "read available space" do
        ALSA::PCM::Native::avail_update(self.handle)
      end
      ALSA.logger.debug { "write synchronously a silence of #{silent_frame_count} frames"}
      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(silent_frame_count)) do |silent|
        ALSA::PCM::Native::writei self.handle, silent, silent_frame_count
      end

      started = true
    end

    def write
      check_handle!

      ALSA.logger.debug { "start write with #{hw_params.inspect}" }

      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(buffer_frame_count)) do |buffer|
        while audio_content = yield(buffer.size)
          buffer.write_string audio_content

          read_frame_count = 
            if audio_content.size == buffer.size
              buffer_frame_count 
            else
              hw_params.frame_count_for(audio_content.size)
            end

          write_buffer buffer, read_frame_count
        end
      end
    end

  end
end
