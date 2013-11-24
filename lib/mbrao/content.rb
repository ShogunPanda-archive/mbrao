# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Setter methods for the {Content Content} class.
  module ContentPublicInterface
    # Checks if the content is available for at least one of the provided locales.
    #
    # @param locales [Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [Boolean] `true` if the content is available for at least one of the desired locales, `false` otherwise.
    def enabled_for_locales?(*locales)
      locales = locales.flatten.ensure_array(nil, false, false, true) {|l| l.ensure_string.strip }.reject {|l| l == "*" }
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

    private
      # Filters an attribute basing a set of locales.
      #
      # @param attribute [Object|HashWithIndifferentAccess] The desired attribute.
      # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
      # @return [String|HashWithIndifferentAccess] Return the object for desired locales. If only one locale is available, then only a object is returned,
      #   else a `HashWithIndifferentAccess` with locales as keys.
      def filter_attribute_for_locales(attribute, locales)
        locales = ::Mbrao::Content.validate_locales(locales, self)

        if attribute.is_a?(HashWithIndifferentAccess) then
          rv = attribute.reduce(HashWithIndifferentAccess.new) { |hash, pair| append_value_for_locale(hash, pair[0], locales, pair[1]) }
          rv.keys.length == 1 ? rv.values.first : rv
        else
          attribute
        end
      end

      # Adds an value on a hash if enable for requested locales.
      #
      # @param hash [Hash] The hash to handle.
      # @param locale [String] The list of locale (separated by commas) for which the value is available.
      # @param locales [Array] The list of locale for which this value is requested. Can include `*` to match all. If none are specified, the default mbrao
      #   locale will be used.
      # @param value [Object] The value to add.
      # @return [Hash] Return the original hash.
      def append_value_for_locale(hash, locale, locales, value)
        locale.split(/\s*,\s*/).map(&:strip).each do |l|
          hash[l] = value if locales.include?("*") || locales.include?(l)
        end

        hash
      end
  end

  # Represents a parsed content, with its metadata.
  #
  # @attribute uid
  #   @return [String] A unique ID for this post. This is only for client uses.
  # @attribute locales
  #   @return [Array] A list of locales for this content should be visible. An empty list means that there are no limitations.
  # @attribute title
  #   @return [String|HashWithIndifferentAccess] The content's title. Can be a `String` or an `HashWithIndifferentAccess`, if multiple titles are specified for
  #     multiple locales.
  # @attribute summary
  #   @return [String|HashWithIndifferentAccess] The content's summary. Can be a `String` or an `HashWithIndifferentAccess`, if multiple summaries are specified
  #     for multiple locales.
  # @attribute body
  #   @return [String] The content's body.
  # @attribute tags
  #   @return [String|HashWithIndifferentAccess] The content's "more link" label. Can be a `String` or an `HashWithIndifferentAccess`, if multiple labels are
  #     specified for multiple locales.
  # @attribute tags
  #   @return [Array|HashWithIndifferentAccess] The tags associated with the content. Can be an `Array` or an `HashWithIndifferentAccess`, if multiple tags set
  #     are specified for multiple locales.
  # @attribute author
  #   @return [Author] The post author.
  # @attribute created_at
  #   @return [DateTime] The post creation date and time. The timezone is always UTC.
  # @attribute updated_at
  #   @return [DateTime] The post creation date and time. Defaults to the creation date. The timezone is always UTC.
  # @attribute metadata
  #   @return [Hash] The full list of metadata of this content.
  class Content
    include Mbrao::ContentPublicInterface

    attr_accessor :uid
    attr_accessor :locales
    attr_accessor :title
    attr_accessor :summary
    attr_accessor :body
    attr_accessor :tags
    attr_accessor :more
    attr_accessor :author
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :metadata

    # Creates a new content.
    #
    # @param uid [String] The UID for this content.
    def initialize(uid = nil)
      @uid = uid
    end

    # Sets the `locales` attribute.
    #
    # @param value [Array] The new value for the attribute. A empty or "*" will be the default value.
    def locales=(value)
      @locales = value.ensure_array(nil, true, true, true) {|l| l.ensure_string.strip }
    end

    # Sets the `title` attribute.
    #
    # @param new_title [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def title=(new_title)
      @title = is_hash?(new_title) ? new_title.ensure_hash(:indifferent, nil, :ensure_string) : new_title.ensure_string
    end

    # Sets the `summary` attribute.
    #
    # @param new_summary [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def summary=(new_summary)
      @summary = is_hash?(new_summary) ? new_summary.ensure_hash(:indifferent, nil, :ensure_string) : new_summary.ensure_string
    end

    # Sets the `body` attribute.
    #
    # @param value [String] The new value for the attribute. Can contain locales restriction (like !en), which will must be interpreted using #get_body.
    def body=(value)
      @body = value.ensure_string
    end

    # Sets the `tags` attribute.
    #
    # @param new_tags [Array|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value. Tags can also be comma-separated.
    def tags=(new_tags)
      @tags = if is_hash?(new_tags) then
        new_tags.ensure_hash(:indifferent) { |v| parse_tags(v) }
      else
        parse_tags(new_tags)
      end
    end

    # Sets the `more` attribute.
    #
    # @param new_more [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def more=(new_more)
      @more = is_hash?(new_more) ? new_more.ensure_hash(:indifferent, nil, :ensure_string) : new_more.ensure_string
    end

    # Sets the `author` attribute.
    #
    # @param new_author [Author|Hash|Object|NilClass] The new value for the attribute.
    def author=(new_author)
      if new_author.is_a?(Mbrao::Author) then
        @author = new_author
      elsif is_hash?(new_author) then
        new_author = new_author.ensure_hash(:indifferent)
        @author = Mbrao::Author.create(new_author)
      else
        @author = new_author ? Mbrao::Author.new(new_author.ensure_string) : nil
      end
    end

    # Sets the `created_at` attribute.
    #
    # @param value [String|DateTime|Fixnum] The new value for the attribute.
    def created_at=(value)
      @created_at = extract_datetime(value)
    end

    # Sets the `updated_at` attribute.
    #
    # @param value [String|DateTime|Fixnum] The new value for the attribute.
    def updated_at=(value)
      @updated_at = extract_datetime(value)
      @updated_at = @created_at if !@updated_at
    end

    # Gets metadata attribute.
    #
    # @return The metadata attribute.
    def metadata
      @metadata ||= HashWithIndifferentAccess.new
    end

    # Sets the `metadata` attribute.
    #
    # @param new_metadata [Hash] The new value for the attribute.
    def metadata=(new_metadata)
      if is_hash?(new_metadata) then
        @metadata = new_metadata.ensure_hash(:indifferent)
      else
        @metadata = HashWithIndifferentAccess.new({raw: new_metadata})
      end
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

    # Validates locales for attribute retrieval.
    #
    # @param locales [Array] A list of desired locales for an attribute. Can include `*` to match all. If none are specified, the default mbrao locale will be
    #   used.
    # @param content [Content|nil] An optional content to check for availability
    # @return [Array] The validated list of locales.
    def self.validate_locales(locales, content = nil)
      locales = locales.ensure_array(nil, true, true, true) {|l| l.ensure_string.strip }
      locales = (locales.empty? ? [Mbrao::Parser.locale] : locales)
      raise Mbrao::Exceptions::UnavailableLocalization.new if content && !content.enabled_for_locales?(locales)
      locales
    end

    # Creates a content with metadata and body.
    #
    # @param metadata [Hash] The metadata.
    # @param body [String] The body of the content.
    # @return [Content] A new content.
    def self.create(metadata, body)
      rv = Mbrao::Content.new
      rv.body = body.ensure_string.strip
      assign_metadata(rv, metadata.symbolize_keys) if metadata.is_a?(Hash)
      rv
    end

    private
      # Assigns metadata to a content
      #
      # @param content [Content] The content to manipulate.
      # @param metadata [Hash] The metadata to assign.
      # @return [Content] The content with metadata.
      def self.assign_metadata(content, metadata)
        content.uid = metadata.delete(:uid)
        content.title = metadata.delete(:title)
        content.summary = metadata.delete(:summary)
        content.author = Mbrao::Author.create(metadata.delete(:author))
        content.tags = metadata.delete(:tags)
        content.more = metadata.delete(:more)
        content.created_at = metadata.delete(:created_at)
        content.updated_at = metadata.delete(:updated_at)
        content.locales = extract_locales(metadata)
        content.metadata = metadata

        content
      end

      # Extract locales from metadata.
      #
      # @param metadata [Hash] The metadata that contains the locales.
      # @return [Array] The locales.
      def self.extract_locales(metadata)
        locales = metadata.delete(:locales)
        locales = locales.ensure_string.split(/\s*,\s*/) if !locales.is_a?(::Array)
        normalize_locales(locales)
      end

      # Normalize locales for further usage.
      #
      # @param locales [Array] The locales to normalize.
      # @return [Array] The normalized locales.
      def self.normalize_locales(locales)
        locales.flatten.map(&:ensure_string).map(&:strip).uniq
      end

      # Extracts a date and time from a value.
      #
      # @param value [String|DateTime|Fixnum] The value to parse.
      # @return [DateTime] The extracted value.
      def extract_datetime(value)
        begin
          value = parse_datetime(value) if value
          value ? value.utc : nil
        rescue ArgumentError
          raise Mbrao::Exceptions::InvalidDate.new
        end
      end

      # Parse a datetime
      # @param value [String|DateTime|Fixnum] The value to parse.
      # @return [DateTime] The extracted value.
      def parse_datetime(value)
        case value.class.to_s
          when "DateTime" then value
          when "Date", "Time" then value.to_datetime
          when "Float", "Fixnum" then
            value.to_float > 0 ? Time.at(value.to_float).to_datetime : nil
          else DateTime.strptime(value.ensure_string, "%Y%m%dT%H%M%S%z")
        end
      end

      # Extract tags from an array, making sure all the comma separated strings are evaluated.
      #
      # @param value [String|Array] The string or array to parse.
      # @return [Array] The list of tags.
      def parse_tags(value)
        value.ensure_array(nil, true, true, true) { |v| v.ensure_string.split(/\s*,\s*/) }
      end

      # Check if value is an Hash.
      #
      # @param value [Object] The object to check.
      # @return [Boolean] `true` if value is an Hash, `false` otherwise
      def is_hash?(value)
        value.is_a?(Hash)
      end
  end
end