# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require File.expand_path("../lib/mbrao/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "mbrao"
  gem.version = Mbrao::Version::STRING
  gem.homepage = "http://sw.cowtech.it/mbrao"
  gem.summary = "A content parser and renderer with embedded metadata support."
  gem.description = "A content parser and renderer with embedded metadata support."
  gem.rubyforge_project = "mbrao"

  gem.authors = ["Shogun"]
  gem.email = ["shogun@cowtech.it"]
  gem.license = "MIT"

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.3.0"

  gem.add_dependency("lazier", "~> 4.2")
  gem.add_dependency("html-pipeline", "~> 2.3")
  gem.add_dependency("slim", "~> 3.0")
  gem.add_dependency("kramdown", "~> 1.10")
  gem.add_dependency("rinku", "~> 1.7")
  gem.add_dependency("gemoji", "~> 2.1")
end
