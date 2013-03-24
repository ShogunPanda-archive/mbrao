# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A content parser and renderer with embedded metadata support.
module Mbrao
  # Methods to allow class level access.
  module PublicInterface
    extend ActiveSupport::Concern

    # Class methods.
    #
    # @attribute default_locale
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
        self.instance.parse(content, options)
      end

      # Renders a content.
      #
      # @param content [Content] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      # @return [String] The rendered content.
      def render(content, options = {}, context = {})
        self.instance.render(content, options, context)
      end

      # Instantiates a new engine for rendering or parsing.
      #
      # @param cls [String|Symbol|Object] If a `String` or a `Symbol`, then it will be the class of the engine.
      # @param type [Symbol] The type or engine. Can be `:parsing` or `:rendering`.
      # @return [Object] A new engine.
      def create_engine(cls, type = :parsing)
        begin
          type = :parsing if type != :rendering
          ::Lazier.find_class(cls, "::Mbrao::#{type.to_s.classify}Engines::%CLASS%").new
        rescue NameError => _
          raise Mbrao::Exceptions::UnknownEngine.new
        end
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
    end
  end

  # Methods to perform validations.
  module Validations
    extend ActiveSupport::Concern

    # Class methods.
    module ClassMethods
      # Checks if the text is a valid email.
      #
      # @param text [String] The text to check.
      # @return [Boolean] `true` if the string is valid email, `false` otherwise.
      def is_email?(text)
        regex = /^([a-z0-9_\.\-\+]+)@([\da-z\.\-]+)\.([a-z\.]{2,6})$/i
        text.ensure_string.strip =~ regex
      end

      # Checks if the text is a valid URL.
      #
      # @param text [String] The text to check.
      # @return [Boolean] `true` if the string is valid URL, `false` otherwise.
      def is_url?(text)
        regex = /
          ^(
            ([a-z0-9\-]+:\/\/) #PROTOCOL
            (([\w-]+\.)?) # LOWEST TLD
            ([\w-]+) # 2nd LEVEL TLD
            (\.[a-z]+) # TOP TLD
            ((:\d+)?) # PORT
            ([\S|\?]*) # PATH, QUERYSTRING AND FRAGMENT
          )$
        /ix

        text.ensure_string.strip =~ regex
      end

      # Converts an object making sure that every `Hash` is converted to a `HashWithIndifferentAccess`.
      #
      # @param object [Object] The object to convert. If the object is not an Hash or doesn't respond to `collect` then the original object is returned.
      # @param sanitize_method [Symbol|nil] If not `nil`, the method to use to sanitize entries. Ignored if a block is present.
      # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
      # @return [Object] The converted object.
      def sanitized_hash(object, sanitize_method = nil, &block)
        if object.is_a?(Hash) || object.is_a?(HashWithIndifferentAccess) then
          object.inject(HashWithIndifferentAccess.new) do |hash, pair|
            hash[pair[0]] = Mbrao::Parser.sanitized_hash(pair[1], sanitize_method, &block)
            hash
          end
        elsif object.respond_to?(:collect) then
          object.collect {|item| Mbrao::Parser.sanitized_hash(item, sanitize_method, &block) }
        else
          sanitized_hash_entry(object, sanitize_method, &block)
        end
      end

      # Converts an object to a a flatten array with all values sanitized.
      #
      # @param object [Object] The object to convert.
      # @param uniq [Boolean] If to remove duplicates from the array before sanitizing.
      # @param compact [Boolean] If to compact the array before sanitizing.
      # @param sanitize_method [Symbol|nil] If not `nil`, the method to use to sanitize entries. Ignored if a block is present.
      # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
      # @return [Array] An flattened array whose all values are strings.
      def sanitized_array(object, uniq = true, compact = false, sanitize_method = :ensure_string, &block)
        rv = object.ensure_array.flatten
        rv.uniq! if uniq
        rv.compact! if compact

        if block then
          rv = rv.collect(&block)
        elsif sanitize_method then
          rv = rv.collect(&sanitize_method)
        end

        rv.uniq! if uniq
        rv.compact! if compact
        rv
      end

      private
        # Sanitizes an value for an hash.
        #
        # @param value [Object] The value to sanitize.
        # @param sanitize_method [Symbol|nil] If not `nil`, the method to use to sanitize the value. Ignored if a block is present.
        # @param block [Proc] A block to sanitize the value. It must accept the value as unique argument.
        def sanitized_hash_entry(value, sanitize_method = :ensure_string, &block)
          if block
            block.call(value)
          elsif sanitize_method
            value.send(sanitize_method)
          else
            value
          end
        end
    end
  end

  # A parser to handle pipelined content.
  #
  class Parser
    include Mbrao::PublicInterface
    include Mbrao::Validations

    # Parses a source text.
    #
    # @param content [Object] The content to parse.
    # @param options [Hash] A list of options for parsing.
    # @return [Content] The parsed data.
    def parse(content, options = {})
      options = sanitize_parsing_options(options)
      ::Mbrao::Parser.create_engine(options[:engine]).parse(content, options)
    end

    # Renders a content.
    #
    # @param content [Content] The content to parse.
    # @param options [Hash] A list of options for renderer.
    # @param context [Hash] A context for rendering.
    # @return [String] The rendered content.
    def render(content, options = {}, context = {})
      options = sanitize_rendering_options(options)
      ::Mbrao::Parser.create_engine(options[:engine], :rendering).render(content, options, context)
    end

    private
      # Sanitizes options for parsing.
      #
      # @param options [Hash] The options to sanitize.
      # @return [HashWithIndifferentAccess] The sanitized options.
      def sanitize_parsing_options(options)
        options = (options.is_a?(Hash) ? options : {}).symbolize_keys

        options[:engine] ||= Mbrao::Parser.parsing_engine
        options[:metadata] = options.fetch(:metadata, true).to_boolean
        options[:content] = options.fetch(:content, true).to_boolean

        HashWithIndifferentAccess.new(options)
      end

      # Sanitizes options for rendering.
      #
      # @param options [Hash] The options to sanitize.
      # @return [HashWithIndifferentAccess] The sanitized options.
      def sanitize_rendering_options(options)
        options = (options.is_a?(Hash) ? options : {}).symbolize_keys

        options[:engine] ||= Mbrao::Parser.rendering_engine

        HashWithIndifferentAccess.new(options)
      end
  end
end