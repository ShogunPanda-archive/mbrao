# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require 'html/pipeline'
require "slim"

require "mbrao/version" if !defined?(Mbrao::Version)
require "mbrao/exceptions"
require "mbrao/content"
require "mbrao/author"
require "mbrao/parser"
require "mbrao/parsing_engines/base"
require "mbrao/parsing_engines/plain_text"

# TODO:
#   Handler for the Rails assets pipeline. Looking at params[:locale] or @locale for rendering the body.
#   If the content is not available for the locale it should raise a ::Mbrao::Exceptions::UnavailableLocale.
#   Also, it should save the Content object in the @mbrao_content of the controller.

Lazier.load!(:object)