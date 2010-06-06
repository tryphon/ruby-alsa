module ALSA::PCM
  class Stream

    attr_accessor :handle
    attr_accessor :buffer_time_size

    def self.open(device = "default", hardware_attributes = {}, &block)
      new.open(device, hardware_attributes, &block)
    end

    def open(device = "default", hardware_attributes = {}, &block)
      options = {}

      if Hash === device
        options = device
        device = (options[:device] or "default")
      end

      self.buffer_time_size = options[:buffer_time_size] if options[:buffer_time_size]

      handle_pointer = FFI::MemoryPointer.new :pointer
      ALSA::try_to "open audio device #{device}" do
        ALSA::PCM::Native::open handle_pointer, device, native_constant, ALSA::PCM::Native::BLOCK
      end
      self.handle = handle_pointer.read_pointer

      self.hardware_parameters = hardware_attributes

      if block_given?
        begin
          yield self 
        ensure
          self.close
        end
      end
    end

    def buffer_time_size
      @buffer_time_size ||= 250
    end

    def buffer_frame_count
      @buffer_frame_count ||= hw_params.sample_rate * buffer_time_size / 1000
    end

    def change_hardware_parameters
      hw_params = ALSA::PCM::HwParameters.new(self).default_for_device

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
      ALSA::PCM::HwParameters.new(self).current_for_device
    end
    alias_method :hw_params, :hardware_parameters

    def hardware_parameters=(attributes= {})
      attributes = { 
        :access => :rw_interleaved, 
        :channels => 2, 
        :sample_format => :s16_le, 
        :sample_rate => 44100 
      }.update(attributes)

      change_hardware_parameters do |hw_params|
        hw_params.update_attributes(attributes)
      end
    end

    def opened?
      not self.handle.nil?
    end

    def check_handle!
      raise "Stream isn't opened" unless opened?
    end

    def close
      ALSA::try_to "close audio device" do
        ALSA::PCM::Native::close self.handle
        self.handle = nil
      end
    end

  end
end
