# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Mbrao
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
    attr_accessor :uid, :locales, :title, :summary, :body, :tags, :more, :author, :created_at, :updated_at, :metadata

    include Mbrao::ContentInterface

    # Creates a new content.
    #
    # @param uid [String] The UID for this content.
    def initialize(uid = nil)
      @uid = uid
    end

    # Gets metadata attribute.
    #
    # @return The metadata attribute.
    def metadata
      @metadata ||= HashWithIndifferentAccess.new
    end

    # Sets the `locales` attribute.
    #
    # @param value [Array] The new value for the attribute. A empty or "*" will be the default value.
    def locales=(value)
      @locales = value.ensure_array(no_duplicates: true, compact: true, flatten: true) { |l| l.ensure_string.strip }
    end

    # Sets the `title` attribute.
    #
    # @param new_title [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def title=(new_title)
      @title = hash?(new_title) ? new_title.ensure_hash(accesses: :indifferent, default: nil, sanitizer: :ensure_string) : new_title.ensure_string
    end

    # Sets the `summary` attribute.
    #
    # @param new_summary [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def summary=(new_summary)
      @summary = hash?(new_summary) ? new_summary.ensure_hash(accesses: :indifferent, default: nil, sanitizer: :ensure_string) : new_summary.ensure_string
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
      @tags = hash?(new_tags) ? new_tags.ensure_hash(accesses: :indifferent) { |v| parse_tags(v) } : parse_tags(new_tags)
    end

    # Sets the `more` attribute.
    #
    # @param new_more [String|Hash] The new value for the attribute. If an Hash, keys must be a string with one or locale separated by commas.
    #   A empty or "*" will be the default value.
    def more=(new_more)
      @more = hash?(new_more) ? new_more.ensure_hash(accesses: :indifferent, default: nil, sanitizer: :ensure_string) : new_more.ensure_string
    end

    # Sets the `author` attribute.
    #
    # @param new_author [Author|Hash|Object|NilClass] The new value for the attribute.
    def author=(new_author)
      @author =
        if new_author.is_a?(Mbrao::Author)
          new_author
        elsif hash?(new_author)
          Mbrao::Author.create(new_author.ensure_hash(accesses: :indifferent))
        else
          new_author ? Mbrao::Author.new(new_author.ensure_string) : nil
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
      @updated_at = extract_datetime(value) || @created_at
    end

    # Sets the `metadata` attribute.
    #
    # @param new_metadata [Hash] The new value for the attribute.
    def metadata=(new_metadata)
      @metadata = hash?(new_metadata) ? new_metadata.ensure_hash(accesses: :indifferent) : @metadata = HashWithIndifferentAccess.new({raw: new_metadata})
    end

    # Assigns metadata to a content
    #
    # @param content [Content] The content to manipulate.
    # @param metadata [Hash] The metadata to assign.
    # @return [Content] The content with metadata.
    def self.assign_metadata(content, metadata)
      [:uid, :title, :summary, :tags, :more, :created_at, :updated_at].each do |field|
        content.send("#{field}=", metadata.delete(field))
      end

      content.author = Mbrao::Author.create(metadata.delete(:author))
      content.locales = extract_locales(metadata.delete(:locales))
      content.metadata = metadata
    end

    # Extracts locales from metadata.
    #
    # @param locales [String] The list of locales.
    # @return [Array] The locales.
    def self.extract_locales(locales)
      locales = locales.ensure_string.split(/\s*,\s*/) unless locales.is_a?(::Array)
      normalize_locales(locales)
    end

    # Normalizes locales for further usage.
    #
    # @param locales [Array] The locales to normalize.
    # @return [Array] The normalized locales.
    def self.normalize_locales(locales)
      locales.flatten.map(&:ensure_string).map(&:strip).uniq
    end

    private

    # :nodoc:
    def extract_datetime(value)
      value = parse_datetime(value) if value
      value ? value.utc : nil
    rescue ArgumentError
      raise Mbrao::Exceptions::InvalidDate
    end

    # :nodoc:
    def parse_datetime(value)
      rv =
        case value.class.to_s
        when "DateTime" then value
        when "Date", "Time" then value.to_datetime
        when "Float", "Fixnum" then parse_datetime_number(value)
        else parse_datetime_string(value)
        end

      raise ArgumentError unless rv
      rv
    end

    # :nodoc:
    def parse_datetime_number(value)
      number = value.to_float
      number > 0 ? Time.at(number).to_datetime : nil
    end

    # :nodoc:
    def parse_datetime_string(value)
      value = value.ensure_string

      catch(:parsed) do
        ALLOWED_DATETIME_FORMATS.find do |format|
          begin
            throw(:parsed, DateTime.strptime(value, format))
          rescue
            nil
          end
        end
      end
    end

    # :nodoc:
    def parse_tags(value)
      value.ensure_array(no_duplicates: true, compact: true, flatten: true) { |v| v.ensure_string.split(/\s*,\s*/) }
    end

    # :nodoc:
    def hash?(value)
      value.is_a?(Hash)
    end
  end
end
