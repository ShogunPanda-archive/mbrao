# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Miscellaneous {Content Content} class methods.
  module ContentInterface
    extend ActiveSupport::Concern

    # The allowed string format for a datetime.
    ALLOWED_DATETIME_FORMATS = [
      "%Y%m%dT%H%M%S%z", "%Y%m%dT%H%M%S%Z",
      "%FT%T.%L%z", "%FT%T.%L%Z",
      "%FT%T%z", "%FT%T%Z",
      "%F %T %z", "%F %T %Z",
      "%F %T.%L %z", "%F %T.%L %Z",

      "%F %T.%L", "%F %T", "%F %H:%M", "%F",
      "%d/%m/%Y %T.%L", "%d/%m/%Y %T", "%d/%m/%Y %H:%M", "%d/%m/%Y"
    ].freeze

    # Class methods.
    module ClassMethods
      # Validates locales for attribute retrieval.
      #
      # @param locales [Array] A list of desired locales for an attribute. Can include `*` to match all. If none are specified, the default mbrao locale will be
      #   used.
      # @param content [Content|nil] An optional content to check for availability
      # @return [Array] The validated list of locales.
      def validate_locales(locales, content = nil)
        locales = locales.ensure_array(no_duplicates: true, compact: true, flatten: true) { |l| l.ensure_string.strip }
        locales = (locales.empty? ? [Mbrao::Parser.locale] : locales)
        raise Mbrao::Exceptions::UnavailableLocalization if content && !content.enabled_for_locales?(locales)
        locales
      end

      # Creates a content with metadata and body.
      #
      # @param metadata [Hash] The metadata.
      # @param body [String] The body of the content.
      # @return [Content] A new content.
      def create(metadata, body)
        rv = Mbrao::Content.new
        rv.body = body.ensure_string.strip
        assign_metadata(rv, metadata.symbolize_keys) if metadata.is_a?(Hash)
        rv
      end
    end

    # Checks if the content is available for at least one of the provided locales.
    #
    # @param locales [Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [Boolean] `true` if the content is available for at least one of the desired locales, `false` otherwise.
    def enabled_for_locales?(*locales)
      locales = locales.flatten.ensure_array(flatten: true) { |l| l.ensure_string.strip }.reject { |l| l == "*" }
      @locales.blank? || locales.blank? || (@locales & locales).present?
    end

    # Gets the title of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [String|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is required, then a `String`
    #   is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_title(locales = [])
      filter_attribute_for_locales(@title, locales)
    end

    # Gets the body returning only the portion which are available for the given locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @param engine [String|Symbol|Object] The engine to use to filter contents.
    # @return [String|HashWithIndifferentAccess] Return the body of the content in the desired locales. If only one locale is required, then a `String`
    #   is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_body(locales = [], engine = :plain_text)
      Mbrao::Parser.create_engine(engine).filter_content(self, locales)
    end

    # Gets the tags of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [Array|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is required, then a `Array`
    #   is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_tags(locales = [])
      filter_attribute_for_locales(@tags, locales)
    end

    # Gets the "more link" text of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [String|HashWithIndifferentAccess] Return the label of the "more link" of the content in the desired locales. If only one locale is required,
    #   then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_more(locales = [])
      filter_attribute_for_locales(@more, locales)
    end

    # Returns the content as an Hash.
    #
    # @param options [Hash] Options to modify behavior of the serialization.
    #   The only supported value are:
    #
    #   * `:exclude`, an array of attributes to skip.
    #   * `:exclude_empty`, if to exclude nil values. Default is `false`.
    # @return [Hash] An hash with all attributes.
    def as_json(options = {})
      keys = [:uid, :locales, :title, :summary, :body, :tags, :more, :author, :created_at, :updated_at, :metadata]
      ::Mbrao::Parser.as_json(self, keys, options)
    end

    private

    # :nodoc:
    def filter_attribute_for_locales(attribute, locales)
      locales = ::Mbrao::Content.validate_locales(locales, self)

      if attribute.is_a?(HashWithIndifferentAccess)
        rv = attribute.reduce(HashWithIndifferentAccess.new) { |a, e| append_value_for_locale(a, e[0], locales, e[1]) }
        rv.keys.length == 1 ? rv.values.first : rv
      else
        attribute
      end
    end

    # :nodoc:
    def append_value_for_locale(hash, locale, locales, value)
      locale.split(/\s*,\s*/).map(&:strip).each do |l|
        hash[l] = value if locales.include?("*") || locales.include?(l)
      end

      hash
    end
  end
end
