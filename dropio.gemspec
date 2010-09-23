# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dropio}
  s.version = "3.0.0.pre7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jake Good, Eric Skiff, Kunal Shah, Seth Thomas Rasmussen, Matthew Rathbone"]
  s.date = %q{2010-09-21}
  s.description = %q{A Ruby client library for the Drop.io Rich Media Backbone (RMB) API (http://backbone.drop.io). Please send all feedback to contact@dropio.com}
  s.email = ["jake@dropio.com", "eric@dropio.com", "kunal@dropio.com", "seth@dropio.com", "matthew@dropio.com"]
  s.extra_rdoc_files = ["History.rdoc", "Readme.rdoc", "Todo.rdoc"]
  s.files = ["Gemfile", "History.rdoc", "LICENSE.txt", "Manifest", "Rakefile", "Readme.rdoc", "Todo.rdoc", "dropio.gemspec", "lib/dropio.rb", "lib/dropio/api.rb", "lib/dropio/asset.rb", "lib/dropio/client.rb", "lib/dropio/drop.rb", "lib/dropio/job.rb", "lib/dropio/resource.rb", "lib/dropio/subscription.rb", "lib/dropio/version.rb", "spec/dropio/api_spec.rb", "spec/dropio/asset_spec.rb", "spec/dropio/client_spec.rb", "spec/dropio/drop_spec.rb", "spec/dropio/subscription_spec.rb", "spec/dropio_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/dropio/dropio}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Dropio", "--main", "Readme.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dropio}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A Ruby client library for the Drop.io Rich Media Backbone (RMB) API (http://backbone.drop.io)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<httparty>, ["= 0.6.1"])
      s.add_runtime_dependency(%q<multipart-post>, ["= 1.0.1"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<diff-lcs>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<httparty>, ["= 0.6.1"])
      s.add_dependency(%q<multipart-post>, ["= 1.0.1"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<diff-lcs>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<httparty>, ["= 0.6.1"])
    s.add_dependency(%q<multipart-post>, ["= 1.0.1"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<diff-lcs>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end
