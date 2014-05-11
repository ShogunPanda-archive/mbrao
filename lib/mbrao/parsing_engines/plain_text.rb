# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

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
        metadata, content, scanner, start_tag, end_tag = prepare_for_separation(content, options)

        if scanner.scan_until(start_tag)
          metadata = scanner.scan_until(end_tag)

          if metadata
            metadata = metadata.partition(end_tag).first
            content = scanner.rest.strip
          end
        end

        [metadata.ensure_string.strip, content]
      end

      # Parses metadata part and returns all valid metadata.
      #
      # @param content [String] The content to parse.
      # @param options [Hash] Options to customize parsing.
      # @return [Hash] All valid metadata for the content.
      def parse_metadata(content, options = {})
        YAML.load(content)
      rescue => e
        if options[:default]
          options[:default]
        else
          raise ::Mbrao::Exceptions::InvalidMetadata, e.to_s
        end
      end

      # Filters content of a post by locale.
      #
      # @param content [Content] The content to filter.
      # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default Mbrao locale will be requested.
      # @param options [Hash] Options to customize parsing.
      # @return [String|HashWithIndifferentAccess] Return the filtered content in the desired locales. If only one locale is required, then a `String` is
      #   returned, else a `HashWithIndifferentAccess` with locales as keys.
      def filter_content(content, locales = [], options = {})
        body = content.body.ensure_string.strip
        content_tags = sanitize_tags(options[:content_tags], ["{{content: %ARGS%}}", "{{/content}}"])
        locales = ::Mbrao::Content.validate_locales(locales, content)

        # Split the content
        result = scan_content(body, content_tags.first, content_tags.last)

        # Now filter results
        perform_filter_content(result, locales)
      end

      private

      # Prepare arguments for separation.
      #
      # @param content [String] The content to separate.
      # @param options [Hash] The options to sanitize.
      # @return [Array] The sanitized arguments.
      def prepare_for_separation(content, options)
        content = content.ensure_string.strip
        meta_tags = sanitize_tags(options[:meta_tags], ["{{metadata}}", "{{/metadata}}"])

        [nil, content.ensure_string.strip, StringScanner.new(content), meta_tags.first, meta_tags.last]
      end

      # Sanitizes tag markers.
      #
      # @param tag [Array|String] The tag to sanitize.
      # @return [Array] Sanitized tags.
      def sanitize_tags(tag, default = ["---"])
        tag = tag.ensure_string.split(/\s*,\s*/).map(&:strip) if tag && !tag.is_a?(Array)
        (tag.present? ? tag : default).slice(0, 2).map { |t| /#{Regexp.quote(t).gsub("%ARGS%", "\\s*(?<args>[^\\n\\}]+,?)*")}/ }
      end

      # Scans a text and content section.
      #
      # @param content [String] The string to scan
      # @param start_tag [Regexp] The tag to match for starting section.
      # @param end_tag [Regexp] The tag to match for ending section.
      # @return [String] The result of the scan.
      def scan_content(content, start_tag, end_tag)
        rv = []
        scanner = StringScanner.new(content)

        # Begin scanning the string
        perform_scan(rv, scanner, start_tag, end_tag) until scanner.eos?

        rv
      end

      # Perform a scan on the text and content.
      #
      # @param rv [String] The string where to put the results.
      # @param scanner [StringScanner] The scanner to use.
      # @param start_tag [Regexp] The tag to match for starting section.
      # @param end_tag [Regexp] The tag to match for ending section.
      def perform_scan(rv, scanner, start_tag, end_tag)
        if scanner.exist?(start_tag) # It may start an embedded content
          # Scan until the start tag, remove the tag from the match and then store to results.
          rv << [scanner.scan_until(start_tag).partition(start_tag).first, "*"]

          # Keep a reference to the start tag
          starting = scanner.matched

          # Now try to match the rightmost occurring closing tag and then append results
          embedded = parse_embedded_content(scanner, start_tag, end_tag)

          # Append results
          rv << get_embedded_content(starting, embedded, start_tag, end_tag)
        else # Append the rest to the result.
          rv << [scanner.rest, "*"]
          scanner.terminate
        end
      end

      # Gets results for an embedded content.
      #
      # @param [String] starting The match starting expression.
      # @param [String] embedded The embedded contents.
      # @param start_tag [Regexp] The tag to match for starting section.
      # @param end_tag [Regexp] The tag to match for ending section.
      # @return [Array] An array which the first element is the list of valid contents and second is the list of valid locales.
      def get_embedded_content(starting, embedded, start_tag, end_tag)
        # Either we have some content or the content was not closed and therefore we ignore this tag.
        embedded.present? ? [scan_content(embedded, start_tag, end_tag), starting.match(start_tag)["args"]] : [starting, "*"]
      end

      # Parses embedded content of a tag
      #
      # @param scanner [StringScanner] The scanner to use.
      # @param start_tag [Regexp] The tag to match for starting section.
      # @param end_tag [Regexp] The tag to match for ending section.
      # @return [String] The embedded content or `nil`, if the content was never closed.
      def parse_embedded_content(scanner, start_tag, end_tag)
        rv = ""
        balance = 1
        embedded_part = scanner.scan_until(end_tag)

        while balance > 0 && embedded_part
          balance += embedded_part.scan(start_tag).count - 1 # -1 Because there is a closure
          embedded_part = embedded_part.partition(end_tag).first if balance == 0 || !scanner.exist?(end_tag) # This is the last occurrence.
          rv << embedded_part
          embedded_part = scanner.scan_until(end_tag) if balance > 0
        end

        rv
      end

      # Filters content by locale.
      #
      # @param content [Array] The content to filter. @see #scan_content.
      # @param locales [Array] The desired locales. Can include `*` to match all.
      # @return [String|nil] Return the filtered content or `nil` if the content must be hidden.
      def perform_filter_content(content, locales)
        content.map { |part|
          part_content = part[0]
          part_locales = parse_locales(part[1])

          if locales_valid?(locales, part_locales)
            part_content.is_a?(Array) ? perform_filter_content(part_content, locales) : part_content
          else
            nil
          end
        }.compact.join("")
      end

      # Parses locales of a content.
      #
      # @param locales [String] The desired locales. Can include `*` to match all. Note that `!*` is ignored.
      # @return [Hash] An hash with valid and invalid locales.
      def parse_locales(locales)
        types = locales.split(/\s*,\s*/).map(&:strip).group_by { |l| l !~ /^!/ ? "valid" : "invalid" }
        types["valid"] ||= []
        types["invalid"] = types.fetch("invalid", []).reject { |l| l == "!*" }.map { |l| l.gsub(/^!/, "") }
        types
      end

      # Checks if all locales in a list are valid for a part.
      #
      # @param locales [Array] The desired locales. Can include `*` to match all.
      # @param part_locales[Hash] An hash with valid and invalid locales.
      # @return [Boolean] `true` if the locales are valid, `false` otherwise.
      def locales_valid?(locales, part_locales)
        valid = part_locales["valid"]
        invalid = part_locales["invalid"]

        locales.include?("*") || valid.include?("*") || ((valid.empty? || (locales & valid).present?) && (locales & invalid).blank?)
      end
    end
  end
end
