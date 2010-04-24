module ALSA
  module Native
    extend FFI::Library
    ffi_lib "asound"

    attach_function :strerror, :snd_strerror, [:int], :string

    def self.error_code?(response)
      response and response < 0
    end
  end
end
