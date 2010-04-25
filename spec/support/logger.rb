require 'fileutils'
FileUtils.mkdir "log" unless File.exists?("log")

ALSA.logger = Logger.new("log/test.log").tap do |logger|
  logger.level = Logger::DEBUG
end
