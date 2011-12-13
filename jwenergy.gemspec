# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jwenergy/version"

Gem::Specification.new do |s|
  s.name        = "jwenergy"
  s.version     = JWEnergy::VERSION
  s.authors     = ["Michael Guterl"]
  s.email       = ["michael@diminishing.org"]
  s.homepage    = ""
  s.summary     = %q{Ruby API wrapper for JW Energy jobs}
  s.description = %q{Ruby API wrapper for JW Energy jobs, uses Nokogiri for scraping}

  s.rubyforge_project = "jwenergy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"

  s.add_runtime_dependency "nokogiri"
end
