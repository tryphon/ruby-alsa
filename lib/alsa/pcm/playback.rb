module ALSA::PCM
  class Playback < Stream

    def native_constant
      ALSA::PCM::Native::STREAM_PLAYBACK
    end

    def write_buffer(buffer, frame_count)
      check_handle!
      
      write_count = ALSA::try_to "write in audio interface" do
        response = ALSA::PCM::Native::writei(self.handle, buffer, frame_count)
        if ALSA::Native::error_code?(response)
          ALSA.logger.warn { "try to recover '#{ALSA::Native::strerror(response)}' on read"}
          ALSA::PCM::Native::pcm_recover(self.handle, response, 1)
        else
          response
        end
      end

      missing_frame_count = frame_count - write_count
      if missing_frame_count > 0
        ALSA.logger.debug { "missing wroted frame count: #{missing_frame_count}"}
      end
    end

    def write
      check_handle!

      frame_count = hw_params.sample_rate / 2
      FFI::MemoryPointer.new(:char, hw_params.buffer_size_for(frame_count)) do |buffer|
        while audio_content = yield(buffer.size)
          buffer.write_string audio_content

          read_frame_count = 
            if audio_content.size == buffer.size 
              frame_count 
            else
              hw_params.frame_count_for(audio_content.size)
            end

          write_buffer buffer, read_frame_count
        end
      end
    end

  end
end
