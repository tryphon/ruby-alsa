module ALSA
  def self.logger
    unless @logger
      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN
    end

    @logger
  end

  def self.logger=(logger); @logger = logger; end
end
