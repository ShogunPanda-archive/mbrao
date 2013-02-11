# encoding: utf-8
#
# This file is part of the mbriao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/mbriao/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "mbriao"
  gem.version = Mbriao::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/mbriao"
  gem.summary = "A pipelined content parser with metadata support."
  gem.description = "A pipelined content parser with metadata support."
  gem.rubyforge_project = "mbriao"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # TODO: OPTIONAL: Apply the folllowing to restrict Ruby version.
  # gem.required_ruby_version = ">= 1.X"

  # TODO: Add dependencies via gem.add_dependency

  # TODO: Add development dependencies via gem.add_development_dependency
end
