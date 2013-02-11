# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require 'html/pipeline'
require "slim"

require "mbrao/version" if !defined?(Mbrao::Version)
require "mbrao/errors"
require "mbrao/content"
require "mbrao/author"
require "mbrao/parser"

Lazier.load!(:object)