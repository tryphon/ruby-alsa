module FFI

  # FIXME : temporary fix problem with asound and .so (submitted patch)
  def self.map_library_name(lib)
    lib = lib.to_s unless lib.kind_of?(String)
    lib = Platform::LIBC if Platform::IS_LINUX && lib == 'c'
    if lib && File.basename(lib) == lib
      ext = ".#{Platform::LIBSUFFIX}"
      lib = Platform::LIBPREFIX + lib unless lib =~ /^#{Platform::LIBPREFIX}/
      lib += ext unless lib =~ /#{Regexp.escape(ext)}$/
    end
    lib
  end

end
