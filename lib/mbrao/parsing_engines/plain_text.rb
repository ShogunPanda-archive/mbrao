# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# TODO:
#   Options must support opening and closing tag for metadata and content. The default is --- meta/content for both.
#   In content, after the name can be a list of locales separated by commas (also with negation, like !it), for filtering. Any content with no locale will never be filtered.

module Mbrao
  # Engines used to parse contents with metadata.
  module ParsingEngines
    # A class for parsing plain text files.
    class PlainText < Mbrao::ParsingEngines::Base
      # Parses a whole post content and return its metadata and content parts.
      #
      # @param content [String] The content to parse.
      # @param options [Hash] Options to customize parsing.
      # @return [Array] An array of metadata and contents parts.
      def separate_components(content, options = {})

      end

      # Parses metadata part and returns all valid metadata
      #
      # @param content [String] The content to parse.
      # @param options [Hash] Options to customize parsing.
      # @return [Hash] All valid metadata for the content.
      def parse_metadata(content, options = {})

      end

      # Filter content of a post by and separate by locale.
      #
      # @param content [Object] The content to parse.
      # @param locales [String|Array] The desired locales. Can include `*` to match all.
      # @param options [Hash] Options to customize parsing.
      # @return [String|HashWithIndifferentAccess] Return the filtered content in the desired locales. If only one locale is required, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
      def filter_content(content, locales = [], options = {})

      end
    end
  end
end