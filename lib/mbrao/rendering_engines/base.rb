# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Engines used to render contents with metadata.
  module RenderingEngines
    # A base class for all renderers.
    class Base
      # Renders a content.
      #
      # @param content [Content|String] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      def render(content, options = {}, context = {})
        raise Mbrao::Exceptions::Unimplemented.new
      end
    end
  end
end