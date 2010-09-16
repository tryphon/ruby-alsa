module ALSA::PCM
  class SwParameters

    attr_accessor :handle, :device

    def initialize(device = nil)
      sw_params_pointer = FFI::MemoryPointer.new :pointer

      ALSA::PCM::Native::sw_params_malloc sw_params_pointer        
      self.handle = sw_params_pointer.read_pointer

      self.device = device if device
    end

    def update_attributes(attributes)
      attributes.each_pair { |name, value| send("#{name}=", value) }
    end

    def current_for_device
      ALSA::try_to "retrieve current hardware parameters" do
        ALSA::PCM::Native::sw_params_current device.handle, self.handle
      end
      self
    end

    def avail_min=(avail_min)
      ALSA::try_to "set avail_min (#{avail_min})" do
        ALSA::PCM::Native::sw_params_set_avail_min self.device.handle, self.handle, avail_min
      end
    end
    alias_method :available_minimum=, :avail_min=

    def avail_min
      value = nil
      ALSA::try_to "get period time" do
        value_pointer = FFI::MemoryPointer.new(:int)
        error_code = ALSA::PCM::Native::sw_params_get_avail_min self.handle, value_pointer
        value = value_pointer.read_int
        value_pointer.free
        error_code
      end
      value
    end
    alias_method :available_minimum, :avail_min

    def free
      ALSA::try_to "unallocate sw_params" do
        ALSA::PCM::Native::sw_params_free self.handle
      end
    end

  end
end
