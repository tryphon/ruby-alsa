module ALSA::PCM

  module Native
    extend FFI::Library
    ffi_lib "libasound.so.2"

    STREAM_PLAYBACK = 0
    STREAM_CAPTURE = 1

    BLOCK = 0
    attach_function :open, :snd_pcm_open, [:pointer, :string, :int, :int], :int
    attach_function :prepare, :snd_pcm_prepare, [ :pointer ], :int
    attach_function :close, :snd_pcm_close, [:pointer], :int

    attach_function :wait, :snd_pcm_wait, [:pointer, :int], :int
    attach_function :avail_update, :snd_pcm_avail_update, [:pointer], :int

    attach_function :readi, :snd_pcm_readi, [ :pointer, :pointer, :ulong ], :long
    attach_function :writei, :snd_pcm_writei, [ :pointer, :pointer, :ulong ], :long

    attach_function :pcm_recover, :snd_pcm_recover, [ :pointer, :int, :int ], :int

    attach_function :hw_params_malloc, :snd_pcm_hw_params_malloc, [:pointer], :int
    attach_function :hw_params_free, :snd_pcm_hw_params_free, [:pointer], :int

    attach_function :hw_params, :snd_pcm_hw_params, [ :pointer, :pointer ], :int
    attach_function :hw_params_any, :snd_pcm_hw_params_any, [:pointer, :pointer], :int
    attach_function :hw_params_current, :snd_pcm_hw_params_current, [ :pointer, :pointer ], :int

    module Access
      MMAP_INTERLEAVED = 0
      MMAP_NONINTERLEAVED = 1
      MMAP_COMPLEX = 2
      RW_INTERLEAVED = 3
      RW_NONINTERLEAVED = 4
    end

    attach_function :hw_params_set_access, :snd_pcm_hw_params_set_access, [ :pointer, :pointer, :int ], :int

    module Format
      S16_LE = 2
    end
    
    attach_function :hw_params_set_format, :snd_pcm_hw_params_set_format, [ :pointer, :pointer, :int ], :int
    attach_function :hw_params_get_format, :snd_pcm_hw_params_get_format, [ :pointer, :pointer ], :int
    attach_function :hw_params_get_rate, :snd_pcm_hw_params_get_rate, [ :pointer, :pointer, :pointer ], :int
    attach_function :hw_params_set_rate_near, :snd_pcm_hw_params_set_rate_near, [ :pointer, :pointer, :pointer, :pointer ], :int
    attach_function :hw_params_set_channels, :snd_pcm_hw_params_set_channels, [ :pointer, :pointer, :uint ], :int
    attach_function :hw_params_get_channels, :snd_pcm_hw_params_get_channels, [ :pointer, :pointer ], :int
    attach_function :hw_params_set_periods, :snd_pcm_hw_params_set_periods, [ :pointer, :pointer, :uint, :int ], :int
    attach_function :hw_params_set_period_time_near, :snd_pcm_hw_params_set_period_time_near, [ :pointer, :pointer, :pointer, :pointer ], :int
    attach_function :hw_params_get_period_time, :snd_pcm_hw_params_get_period_time, [ :pointer, :pointer, :pointer ], :int

    attach_function :sw_params, :snd_pcm_sw_params, [:pointer, :pointer], :int
    attach_function :sw_params_malloc, :snd_pcm_sw_params_malloc, [:pointer], :int
    attach_function :sw_params_free, :snd_pcm_sw_params_free, [:pointer], :int
    attach_function :sw_params_current, :snd_pcm_sw_params_current, [ :pointer, :pointer ], :int
    attach_function :sw_params_set_avail_min, :snd_pcm_sw_params_set_avail_min, [ :pointer, :pointer, :uint ], :int
    attach_function :sw_params_get_avail_min, :snd_pcm_sw_params_get_avail_min, [ :pointer, :pointer ], :int

    attach_function :format_size, :snd_pcm_format_size, [ :int, :uint ], :int
    attach_function :bytes_to_frames, :snd_pcm_bytes_to_frames, [ :pointer, :int ], :int
  end
end
