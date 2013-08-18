# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Engines used to parse contents with metadata.
  module ParsingEngines
    # A base class for all parsers.
    class Base
      # Parses a whole post content and return its metadata and content parts.
      #
      # @param content [Object] The content to parse.
      # @param options [Hash] Options to customize parsing.
      # @return [Array] An array of metadata and contents parts.
      def separate_components(content, options = {})
        raise Mbrao::Exceptions::Unimplemented.new
      end

      # Parses metadata part and returns all valid metadata.
      #
      # @param content [Object] The content to parse.
      # @param options [Hash] Options to customize parsing.
      # @return [Hash] All valid metadata for the content.
      def parse_metadata(content, options = {})
        raise Mbrao::Exceptions::Unimplemented.new
      end

      # Filters content of a post by locale.
      #
      # @param content [Content] The content to filter.
      # @param locales [String|Array] The desired locales. Can include `*` to match all.
      # @param options [Hash] Options to customize parsing.
      # @return [String|HashWithIndifferentAccess] Return the filtered content in the desired locales. If only one locale is required, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
      def filter_content(content, locales = [], options = {})
        raise Mbrao::Exceptions::Unimplemented.new
      end

      # Parses a content and return a {Content Content} object.
      #
      # @param content [Object] The content to parse.
      # @param options [Hash] Options to customize parsing.
      def parse(content, options = {})
        metadata, body = separate_components(content, options)
        metadata = parse_metadata(metadata, options)
        Mbrao::Content.create(metadata, body)
      end
    end
  end
end