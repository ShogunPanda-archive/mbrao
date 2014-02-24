# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require "html/pipeline"
require "slim"
require "kramdown"
require "yaml"

require "mbrao/version" if !defined?(Mbrao::Version)
require "mbrao/exceptions"
require "mbrao/content"
require "mbrao/author"
require "mbrao/parser"
require "mbrao/parsing_engines/base"
require "mbrao/parsing_engines/plain_text"
require "mbrao/rendering_engines/base"
require "mbrao/rendering_engines/html_pipeline"
require "mbrao/integrations/rails" if defined?(ActionView)

if !defined?(ActiveSupport.use_standard_json_time_format) then
  def ActiveSupport.use_standard_json_time_format
    true
  end
end

Lazier.load!(:object, :hash)
