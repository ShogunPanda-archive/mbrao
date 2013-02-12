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
    # @param locales [Array] The desired locales.
    # @return [Boolean] `true` if the content is available for at least one of the desired locales, `false` otherwise.
    def enabled_for_locales?(*locales)
      locales = Mbrao::Parser.sanitized_array(locales)
      @locales.blank? || locales.blank? || (@locales & locales).present?
    end

    # Gets the title of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales.
    # @return [String|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is available, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_title(locales = [])
      filter_attribute_for_locales(@title, locales)
    end

    # Gets the body of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales.
    # @return [String|HashWithIndifferentAccess] Return the bold of the content in the desired locales. If only one locale is available, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_body(locales = [])
      filter_attribute_for_locales(@body, locales)
    end

    # Gets the tags of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales.
    # @return [Array|HashWithIndifferentAccess] Return the title of the content in the desired locales. If only one locale is available, then a `Array` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_tags(locales = [])
      filter_attribute_for_locales(@tags, locales)
    end

    # Gets the "more link" text of the content in the desired locales.
    #
    # @param locales [String|Array] The desired locales.
    # @return [String|HashWithIndifferentAccess] Return the label of the "more link" of the content in the desired locales. If only one locale is available, then a `String` is returned, else a `HashWithIndifferentAccess` with locales as keys.
    def get_more(locales = [])
      filter_attribute_for_locales(@more, locales)
    end

    private
      # Filter an attribute basing a set of locales.
      #
      # @param attribute [Object|HashWithIndifferentAccess] The desired attribute.
      # @param locales [String|Array] The desired locales.
      # @return [String|HashWithIndifferentAccess] Return the object for desired locales. If only one locale is available, then only a object is returned, else a `HashWithIndifferentAccess` with locales as keys.
      def filter_attribute_for_locales(attribute, locales)
        locales = Mbrao::Parser.sanitized_array(locales)
        locales = [Mbrao::Parser.default_locale] if locales.empty?
        raise Mbrao::Errors::UnavailableLocale.new if !self.enabled_for_locales?(locales)

        if attribute.is_a?(HashWithIndifferentAccess) then
          rv = attribute.select {|k, v| locales.include?(k) }
          rv = rv.keys.length == 1 ? rv.values.first : HashWithIndifferentAccess.new(rv)
        else
          attribute
        end
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

    def initialize(uid = nil)
      @uid = uid
    end

    # Sets the `locales` attribute.
    #
    # @param value [Array] The new value for the attribute.
    def locales=(value)
      @locales = Mbrao::Parser.sanitized_array(value)
    end

    # Sets the `title` attribute.
    #
    # @param value [String|Hash] The new value for the attribute.
    def title=(value)
      @title = value.is_a?(Hash) ? Mbrao::Parser.sanitized_hash(value, :ensure_string) : value.ensure_string
    end

    # Sets the `body` attribute.
    #
    # @param value [String|Hash] The new value for the attribute.
    def body=(value)
      @body = value.is_a?(Hash) ? Mbrao::Parser.sanitized_hash(value, :ensure_string) : value.ensure_string
    end

    # Sets the `tags` attribute.
    #
    # @param value [Array|Hash] The new value for the attribute.
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
    # @param value [String|Hash] The new value for the attribute.
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

    private
      # Extract a date and time from a value.
      #
      # @param value [String|DateTime|Fixnum] The value to parse.
      # @return [DateTime] The extract values.
      def extract_datetime(value)
        begin
          if value.is_a?(Date) || value.is_a?(Time) then
            value = value.to_datetime
          elsif value.is_a?(Fixnum)
            value = Time.at(value).to_datetime
          elsif !value.is_a?(DateTime) then
            value = DateTime.strptime(value.ensure_string, "%Y%m%dT%H%M%S%z")
          end

          value.utc
        rescue ArgumentError => e
          raise Mbrao::Errors::InvalidDate.new
        end
      end
  end
end