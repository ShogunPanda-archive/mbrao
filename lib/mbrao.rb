# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "lazier"
require "html/pipeline"
require "slim"
require "kramdown"
require "yaml"
require "active_support/json/encoding"

require "mbrao/version" unless defined?(Mbrao::Version)
require "mbrao/exceptions"
require "mbrao/content_interface"
require "mbrao/content"
require "mbrao/author"
require "mbrao/parser_interface"
require "mbrao/parser_validations"
require "mbrao/parser"
require "mbrao/parsing_engines/base"
require "mbrao/parsing_engines/plain_text"
require "mbrao/rendering_engines/html_pipeline/kramdown_filter"
require "mbrao/rendering_engines/base"
require "mbrao/rendering_engines/html_pipeline"
require "mbrao/integrations/rails" if defined?(ActionView)

Lazier.load!(:object, :hash, :boolean)
