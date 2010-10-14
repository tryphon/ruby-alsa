module ALSA::PCM
  class HwParameters

    attr_accessor :handle, :device

    def initialize(device = nil)
      hw_params_pointer = FFI::MemoryPointer.new :pointer

      ALSA::PCM::Native::hw_params_malloc hw_params_pointer        
      self.handle = hw_params_pointer.read_pointer

      self.device = device if device
    end

    def update_attributes(attributes)
      attributes.each_pair { |name, value| send("#{name}=", value) }
    end

    def default_for_device
      ALSA::try_to "initialize hardware parameter structure" do
        ALSA::PCM::Native::hw_params_any device.handle, self.handle
      end
      self
    end

    def current_for_device
      ALSA::try_to "retrieve current hardware parameters" do
        ALSA::PCM::Native::hw_params_current device.handle, self.handle
      end
      self
    end

    def access=(access)
      ALSA::try_to "set access type" do
        ALSA::PCM::Native::hw_params_set_access self.device.handle, self.handle, ALSA::PCM::Native::Access.const_get(access.to_s.upcase)
      end
    end

    def channels=(channels)
      ALSA::try_to "set channel count : #{channels}" do
        ALSA::PCM::Native::hw_params_set_channels self.device.handle, self.handle, channels
      end
    end

    def sample_rate=(sample_rate)
      ALSA::try_to "set sample rate" do
        rate = FFI::MemoryPointer.new(:int)
        rate.write_int(sample_rate)

        dir = FFI::MemoryPointer.new(:int)
        dir.write_int(0)

        error_code = ALSA::PCM::Native::hw_params_set_rate_near self.device.handle, self.handle, rate, dir

        rate.free
        dir.free

        error_code
      end
    end

    def period_time=(period_time)
      ALSA::try_to "set period time (#{period_time})" do
        value = FFI::MemoryPointer.new(:int)
        value.write_int(period_time)

        dir = FFI::MemoryPointer.new(:int)
        dir.write_int(-1)
        error_code = ALSA::PCM::Native::hw_params_set_period_time_near self.device.handle, self.handle, value, dir

        value.free
        dir.free

        error_code
      end
    end

    def period_time
      value = nil
      ALSA::try_to "get period time" do
        value_pointer = FFI::MemoryPointer.new(:int)
        dir_pointer = FFI::MemoryPointer.new(:int)
        dir_pointer.write_int(0)

        error_code = ALSA::PCM::Native::hw_params_get_period_time self.handle, value_pointer, dir_pointer

        value = value_pointer.read_int

        value_pointer.free
        dir_pointer.free

        error_code
      end
      value
    end

    def buffer_time=(buffer_time)
      ALSA::try_to "set buffer time (#{buffer_time})" do
        value = FFI::MemoryPointer.new(:int)
        value.write_int(buffer_time)

        dir = FFI::MemoryPointer.new(:int)
        dir.write_int(-1)
        error_code = ALSA::PCM::Native::hw_params_set_buffer_time_near self.device.handle, self.handle, value, dir

        value.free
        dir.free

        error_code
      end
    end

    def sample_rate
      rate = nil
      ALSA::try_to "get sample rate" do
        rate_pointer = FFI::MemoryPointer.new(:int)

        dir_pointer = FFI::MemoryPointer.new(:int)
        dir_pointer.write_int(0)

        error_code = ALSA::PCM::Native::hw_params_get_rate self.handle, rate_pointer, dir_pointer

        rate = rate_pointer.read_int

        rate_pointer.free
        dir_pointer.free

        error_code
      end
      rate
    end

    def sample_format=(sample_format)
      ALSA::try_to "set sample format" do
        ALSA::PCM::Native::hw_params_set_format self.device.handle, self.handle, ALSA::PCM::Native::Format.const_get(sample_format.to_s.upcase)
      end
    end

    def sample_format
      format = nil
      FFI::MemoryPointer.new(:int) do |format_pointer|
        ALSA::try_to "get sample format" do
          ALSA::PCM::Native::hw_params_get_format self.handle, format_pointer
        end
        format = format_pointer.read_int
      end
      format
    end

    def channels
      channels = nil
      FFI::MemoryPointer.new(:int) do |channels_pointer|
        ALSA::try_to "get channels" do
          ALSA::PCM::Native::hw_params_get_channels self.handle, channels_pointer
        end
        channels = channels_pointer.read_int
      end
      channels
    end

    def period_size
      value = nil
      ALSA::try_to "get period size" do
        value_pointer = FFI::MemoryPointer.new(:int)
        dir_pointer = FFI::MemoryPointer.new(:int)
        dir_pointer.write_int(0)

        error_code = ALSA::PCM::Native::hw_params_get_period_size self.handle, value_pointer, dir_pointer

        value = value_pointer.read_int

        value_pointer.free
        dir_pointer.free

        error_code
      end
      value
    end

    def buffer_size
      value = nil
      ALSA::try_to "get buffer size" do
        value_pointer = FFI::MemoryPointer.new(:int)
        error_code = ALSA::PCM::Native::hw_params_get_buffer_size self.handle, value_pointer
        value = value_pointer.read_int

        value_pointer.free

        error_code
      end
      value
    end

    def buffer_size_for(frame_count)
      ALSA::PCM::Native::format_size(self.sample_format, frame_count) * self.channels
    end

    def frame_count_for(byte_count)
      ALSA::PCM::Native::bytes_to_frames(self.device.handle, byte_count)
    end

    def free
      ALSA::try_to "unallocate hw_params" do
        ALSA::PCM::Native::hw_params_free self.handle
      end
    end

    def inspect
      "#<ALSA::PCM::HwParameters:#{object_id} sample_rate=#{sample_rate}, channels=#{channels}, period_time=#{period_time}, period_size=#{period_size}, buffer_size=#{buffer_size}>"
    end

  end
end
