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
      # @param _content [Content|String] The content to parse.
      # @param _options [Hash] A list of options for renderer.
      # @param _context [Hash] A context for rendering.
      def render(_content, _options = {}, _context = {})
        raise Mbrao::Exceptions::Unimplemented
      end
    end
  end
end
