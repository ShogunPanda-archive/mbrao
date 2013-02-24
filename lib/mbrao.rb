# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require "html/pipeline"
require "slim"
require "kramdown"

require "mbrao/version" if !defined?(Mbrao::Version)
require "mbrao/exceptions"
require "mbrao/content"
require "mbrao/author"
require "mbrao/parser"
require "mbrao/parsing_engines/base"
require "mbrao/parsing_engines/plain_text"
require "mbrao/rendering_engines/base"
require "mbrao/rendering_engines/html_pipeline"
require "mbrao/integrations/rails"

Lazier.load!(:object)
