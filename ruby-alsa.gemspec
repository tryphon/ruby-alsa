# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-alsa}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alban Peignier"]
  s.date = %q{2010-06-01}
  s.description = %q{FIX (describe your package)}
  s.email = ["alban@tryphon.eu"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".autotest", "COPYING", "COPYRIGHT", "Gemfile", "History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/alsa.rb", "lib/alsa/logger.rb", "lib/alsa/native.rb", "lib/alsa/pcm/capture.rb", "lib/alsa/pcm/hw_parameters.rb", "lib/alsa/pcm/native.rb", "lib/alsa/pcm/playback.rb", "lib/alsa/pcm/stream.rb", "log/test.log", "ruby-alsa.gemspec", "script/console", "script/destroy", "script/generate", "script/play", "script/record", "spec.html", "spec/alsa/logger_spec.rb", "spec/alsa/native_spec.rb", "spec/alsa/pcm/capture_spec.rb", "spec/alsa/pcm/native_spec.rb", "spec/alsa/pcm/playback_spec.rb", "spec/alsa/pcm/stream_spec.rb", "spec/alsa/pcm_spec.rb", "spec/alsa_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/support/logger.rb", "tasks/buildbot.rake", "tasks/rspec.rake"]
  s.homepage = %q{http://projects.tryphon.eu/ruby-alsa}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-alsa}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{FIX (describe your package)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 0.6.3"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.0"])
    else
      s.add_dependency(%q<ffi>, [">= 0.6.3"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.0"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 0.6.3"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.0"])
  end
end
