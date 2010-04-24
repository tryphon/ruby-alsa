# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-alsa}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alban Peignier"]
  s.date = %q{2010-04-24}
  s.description = %q{FIX (describe your package)}
  s.email = ["alban@tryphon.eu"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["Gemfile", "History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/alsa.rb", "script/console", "script/destroy", "script/generate", "spec/alsa/pcm_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/#{github_username}/#{project_name}}
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
