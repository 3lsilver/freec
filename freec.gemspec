# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{freec}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jan Kubr"]
  s.date = %q{2009-01-23}
  s.description = %q{Layer between your voice app and Freeswitch.}
  s.email = %q{hi@jankubr.com}
  s.extra_rdoc_files = ["lib/call_variables.rb", "lib/freec.rb", "lib/freec_base.rb", "lib/freec_logger.rb", "lib/freeswitch_applications.rb", "README.rdoc"]
  s.files = ["lib/call_variables.rb", "lib/freec.rb", "lib/freec_base.rb", "lib/freec_logger.rb", "lib/freeswitch_applications.rb", "Manifest", "Rakefile", "README.rdoc", "spec/call_variables_spec.rb", "spec/freec_spec.rb", "spec/freeswitch_applications_spec.rb", "spec/sample_call_variables.rb", "spec/spec_helper.rb", "freec.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jankubr/freec}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Freec", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{freec}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Layer between your voice app and Freeswitch.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<extlib>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<daemons>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<extlib>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<extlib>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
