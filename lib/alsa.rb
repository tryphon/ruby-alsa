$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ffi'

module ALSA

  VERSION = "0.0.5"

end

require 'logger'
require 'alsa/logger'
require 'alsa/native'
require 'alsa/pcm/native'
require 'alsa/pcm/hw_parameters'
require 'alsa/pcm/stream'
require 'alsa/pcm/capture'
require 'alsa/pcm/playback'

module ALSA

  def self.try_to(message, &block)
    logger.debug { message }
    if ALSA::Native::error_code?(response = yield)
      raise "cannot #{message} (#{ALSA::Native::strerror(response)})"
    else
      response
    end
  end

end
