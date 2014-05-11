# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A content parser and renderer with embedded metadata support.
module Mbrao
  # Methods to allow class level access.
  module ParserInterface
    extend ActiveSupport::Concern

    # Class methods.
    #
    # @attribute locale
    #   @return [String] The mbrao default locale.
    # @attribute parsing_engine
    #   @return [String] The default parsing engine.
    # @attribute rendering_engine
    #   @return [String] The default rendering engine.
    module ClassMethods
      attr_accessor :locale
      attr_accessor :parsing_engine
      attr_accessor :rendering_engine

      # Gets the default locale for mbrao.
      #
      # @return [String] The default locale.
      def locale
        attribute_or_default(@locale, "en")
      end

      # Gets the default parsing engine.
      #
      # @return [String] The default parsing engine.
      def parsing_engine
        attribute_or_default(@parsing_engine, :plain_text, :to_sym)
      end

      # Gets the default rendering engine.
      #
      # @return [String] The default rendering engine.
      def rendering_engine
        attribute_or_default(@rendering_engine, :html_pipeline, :to_sym)
      end

      # Parses a source text.
      #
      # @param content [Object] The content to parse.
      # @param options [Hash] A list of options for parsing.
      # @return [Content] The parsed data.
      def parse(content, options = {})
        instance.parse(content, options)
      end

      # Renders a content.
      #
      # @param content [Content] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      # @return [String] The rendered content.
      def render(content, options = {}, context = {})
        instance.render(content, options, context)
      end

      # Returns an object as a JSON compatible hash
      #
      # @param target [Object] The target to serialize.
      # @param keys [Array] The attributes to include in the serialization.
      # @param options [Hash] Options to modify behavior of the serialization.
      #   The only supported value are:
      #
      #   * `:exclude`, an array of attributes to skip.
      #   * `:exclude_empty`, if to exclude nil values. Default is `false`.
      # @return [Hash] An hash with all attributes.
      def as_json(target, keys, options = {})
        include_empty = !options[:exclude_empty].to_boolean
        exclude = options[:exclude].ensure_array(nil, true, true, true, :ensure_string)
        keys = keys.ensure_array(nil, true, true, true, :ensure_string)

        map_to_json(target, (keys - exclude), include_empty)
      end

      # Instantiates a new engine for rendering or parsing.
      #
      # @param cls [String|Symbol|Object] If a `String` or a `Symbol`, then it will be the class of the engine.
      # @param type [Symbol] The type or engine. Can be `:parsing` or `:rendering`.
      # @return [Object] A new engine.
      def create_engine(cls, type = :parsing)
        type = :parsing if type != :rendering
        ::Lazier.find_class(cls, "::Mbrao::#{type.to_s.classify}Engines::%CLASS%").new
      rescue NameError
        raise Mbrao::Exceptions::UnknownEngine
      end

      # Returns a unique (singleton) instance of the parser.
      #
      # @param force [Boolean] If to force recreation of the instance.
      # @return [Parser] The unique (singleton) instance of the parser.
      def instance(force = false)
        @instance = nil if force
        @instance ||= Mbrao::Parser.new
      end

      private

      # Returns an attribute or a default value.
      #
      # @param attr [Object ]The attribute to return.
      # @param default_value [Object] The value to return if `attr` is blank.
      # @param sanitizer [Symbol] An optional method to sanitize the returned value.
      def attribute_or_default(attr, default_value = nil, sanitizer = :ensure_string)
        rv = attr.present? ? attr : default_value
        rv = rv.send(sanitizer) if sanitizer
        rv
      end

      # Perform the mapping to JSON.
      #
      # @param target [Object] The target to serialize.
      # @param keys [Array] The attributes to include in the serialization.
      # @param include_empty [Boolean], if to include nil values.
      # @return [Hash] An hash with all attributes.
      def map_to_json(target, keys, include_empty)
        keys.reduce({}) { |rv, key|
          value = get_json_field(target, key)
          rv[key] = value if include_empty || value.present?
          rv
        }.deep_stringify_keys
      end

      # Get a field as JSON.
      #
      # @param target [Object] The object containing the value.
      # @param method [Symbol] The method containing the value.
      def get_json_field(target, method)
        value = target.send(method)
        value = value.as_json if value && value.respond_to?(:as_json) && !value.is_a?(Symbol)
        value
      end
    end
  end
end
