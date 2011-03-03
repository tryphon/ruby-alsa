# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "alsa/version"

Gem::Specification.new do |s|
  s.name        = "ruby-alsa"
  s.version     = ALSA::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alban Peignier", "Florent Peyraud"]
  s.email       = ["alban@tryphon.eu","florent@tryphon.eu"]
  s.homepage    = %q{http://projects.tryphon.eu/ruby-alsa}
  s.summary     = %q{ALSA binding for Ruby}
  s.description = %q{Play and record sound via ALSA library}

  s.rubyforge_project = "ruby-alsa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "autotest"
  s.add_development_dependency "rcov"
  s.add_development_dependency "rake"
  s.add_development_dependency "rake-debian-build"

  s.add_runtime_dependency(%q<ffi>, [">= 0.6.3"])
end
