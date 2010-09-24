module ALSA
  module Native
    extend FFI::Library
    ffi_lib "libasound.so.2"

    attach_function :strerror, :snd_strerror, [:int], :string

    def self.error_code?(response)
      response and response < 0
    end

    callback :async_callback, [:pointer], :void
    attach_function :async_add_pcm_handler, :snd_async_add_pcm_handler, [ :pointer, :pointer, :async_callback, :pointer ], :int
    attach_function :async_handler_get_pcm, :snd_async_handler_get_pcm, [ :pointer ], :pointer
    attach_function :async_handler_get_callback_private, :snd_async_handler_get_callback_private, [ :pointer ], :pointer
  end
end
