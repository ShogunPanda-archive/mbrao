# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
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
      locales = Mbrao::Parser.sanitized_array(locales).collect(&:strip).reject {|l| l == "*" }
      @locales.blank? || locales.blank? || (@locales & locales).present?
    end

    # Gets the title of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [String|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is required, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_title(locales = [])
      filter_attribute_for_locales(@title, locales)
    end

    # Gets the body returning only the portion which are available for the given locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @param engine [String|Symbol|Object] The engine to use to filter contents.
    # @return [String|HashWithIndifferentAccess] Return the body of the content in the desired locales. If only one locale is required, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_body(locales = [], engine = :plain_text)
      Mbrao::Parser.create_engine(engine).filter_content(self, locales)
    end

    # Gets the tags of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [Array|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is required, then a `Array` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_tags(locales = [])
      filter_attribute_for_locales(@tags, locales)
    end

    # Gets the "more link" text of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @return [String|HashWithIndifferentAccess] Return the label of the "more link" of the content in the desired locales. If only one locale is required, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_more(locales = [])
      filter_attribute_for_locales(@more, locales)
    end

    private
      # Filters an attribute basing a set of locales.
      #
      # @param attribute [Object|HashWithIndifferentAccess] The desired attribute.
      # @param locales [String|Array] The desired locales. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
      # @return [String|HashWithIndifferentAccess] Return the object for desired locales. If only one locale is available, then only a object is returned, else a `HashWithIndifferentAccess` with locales as keys.
      def filter_attribute_for_locales(attribute, locales)
        locales = ::Mbrao::Content.validate_locales(locales, self)

        if attribute.is_a?(HashWithIndifferentAccess) then
          rv = attribute.inject(HashWithIndifferentAccess.new) { |hash, pair| append_value_for_locale(hash, pair[0], locales, pair[1]) }
          rv.keys.length == 1 ? rv.values.first : rv
        else
          attribute
        end
      end

      # Adds an value on a hash if enable for requested locales.
      #
      # @param hash [Hash] The hash to handle.
      # @param locale [String] The list of locale (separated by commas) for which the value is available.
      # @param locales [Array] The list of locale for which this value is requested. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
      # @param value [Object] The value to add.
      # @return [Hash] Return the original hash.
      def append_value_for_locale(hash, locale, locales, value)
        locale.split(/\s*,\s*/).collect(&:strip).each do |l|
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
  #   @return [String|HashWithIndifferentAccess] The content's title. Can be a `String` or an `HashWithIndifferentAccess`, if multiple title are specified for multiple locales.
  # @attribute body
  #   @return [String|HashWithIndifferentAccess] The content's body. Can be a `String` or an `HashWithIndifferentAccess`, if multiple contents are specified for multiple locales.
  # @attribute tags
  #   @return [String|HashWithIndifferentAccess] The content's "more link" label. Can be a `String` or an `HashWithIndifferentAccess`, if multiple labels are specified for multiple locales.
  # @attribute tags
  #   @return [Array|HashWithIndifferentAccess] The tags associated with the content. Can be an `Array` or an `HashWithIndifferentAccess`, if multiple tags set are specified for multiple locales.
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
    # @param value [Array] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas. A empty or "*" will be the default value.
    def locales=(value)
      @locales = Mbrao::Parser.sanitized_array(value)
    end

    # Sets the `title` attribute.
    #
    # @param value [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas. A empty or "*" will be the default value.
    def title=(value)
      @title = value.is_a?(Hash) ? Mbrao::Parser.sanitized_hash(value, :ensure_string) : value.ensure_string
    end

    # Sets the `body` attribute.
    #
    # @param value [String] The new value for the attribute. Can contain locales restriction (like !en), which will must be interpreted using #get_body.
    def body=(value)
      @body = value.ensure_string
    end

    # Sets the `tags` attribute.
    #
    # @param value [Array|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas. A empty or "*" will be the default value.
    def tags=(value)
      @tags = if value.is_a?(Hash) then
        values = Mbrao::Parser.sanitized_hash(value)
        values.each {|k, v| values[k] = Mbrao::Parser.sanitized_array(v, true, true) }
        @tags = values
      else
        Mbrao::Parser.sanitized_array(value, true, true)
      end
    end

    # Sets the `more` attribute.
    #
    # @param value [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas. A empty or "*" will be the default value.
    def more=(value)
      @more = value.is_a?(Hash) ? Mbrao::Parser.sanitized_hash(value, :ensure_string) : value.ensure_string
    end

    # Sets the `author` attribute.
    #
    # @param value [Author|Hash|Object] The new value for the attribute.
    def author=(value)
      if value.is_a?(Mbrao::Author) then
        @author = value
      elsif value.is_a?(Hash) then
        value = Mbrao::Parser.sanitized_hash(value, nil)
        @author = Mbrao::Author.new(value["name"], value["email"], value["website"], value["image"], value["metadata"], value["uid"])
      else
        @author = Mbrao::Author.new(value.ensure_string)
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
      @metadata || {}
    end

    # Sets the `metadata` attribute.
    #
    # @param value [Hash] The new value for the attribute.
    def metadata=(value)
      if value.is_a?(Hash) then
        @metadata = Mbrao::Parser.sanitized_hash(value)
      else
        @metadata = HashWithIndifferentAccess.new({raw: value})
      end
    end

    # Validates locales for attribute retrieval.
    #
    # @param locales [Array] A list of desired locales for an attribute. Can include `*` to match all. If none are specified, the default mbrao locale will be used.
    # @param content [Content|nil] An optional content to check for availability
    # @return [Array] The validated list of locales.
    def self.validate_locales(locales, content = nil)
      locales = Mbrao::Parser.sanitized_array(locales).collect(&:strip)
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
      assign_metadata(rv, metadata) if metadata.is_a?(Hash)
      rv
    end

    private
      # Assigns metadata to a content
      #
      # @param content [Content] The content to manipulate.
      # @param metadata [Hash] The metadata to assign.
      # @return [Content] The content with metadata.
      def self.assign_metadata(content, metadata)
        metadata = metadata.symbolize_keys!

        content.uid = metadata.delete(:uid)
        content.title = metadata.delete(:title)
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
        locales.flatten.collect(&:ensure_string).collect(&:strip).uniq
      end

      # Extracts a date and time from a value.
      #
      # @param value [String|DateTime|Fixnum] The value to parse.
      # @return [DateTime] The extract values.
      def extract_datetime(value)
        begin
          if value.is_a?(Date) || value.is_a?(Time) then
            value = value.to_datetime
          elsif value.to_float > 0 then
            value = Time.at(value.to_float).to_datetime
          elsif value && !value.is_a?(DateTime) then
            value = DateTime.strptime(value.ensure_string, "%Y%m%dT%H%M%S%z")
          end

          value ? value.utc : nil
        rescue ArgumentError => _
          raise Mbrao::Exceptions::InvalidDate.new
        end
      end
  end
end