# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# TODO: Handler for assets pipeline. Looking at params[:locale] or @locale, if is not available, it should raise a UnavailableLocaleError. Also, it should save the Content object in the @mbrao_view_content of the controller.

# A content parser and renderer with embedded metadata support.
module Mbrao
  # Methods to allow class level access.
  module PublicInterface
    extend ActiveSupport::Concern

    # Class methods.
    #
    # @attribute default_locale
    #   @return [String] The Mbrao default locale.
    # @attribute marker
    #   @return [Array] The opening and closing markers used for looking for metadata and locale in elements. If a string or single element array, it will used for both. Default is `["---"]`.
    module ClassMethods
      attr_accessor :default_locale
      attr_accessor :marker

      # Sets the default locale for Mbrao.
      #
      # @param value [String|Symbol] The new default locale.
      def default_locale=(value)
        @default_locale = value.ensure_string
      end

      # Gets the markers for Mbrao parsing.
      #
      # @return value [Array] The markers to use for Mbrao parsing.
      def marker
        @marker ||= ["---"]
      end

      # Sets the markers for Mbrao parsing.
      #
      # @param value [String|Array] The new marker.
      def marker=(value)
        @marker = value.ensure_array.compact.collect(&:ensure_string).slice(0, 2)
      end

      # Registers a renderer for contents.
      #
      # @param name [String|Symbol] The name of this renderer.
      # @param block [Proc] The block to execute to render contents. It must have the same interface of the #render.
      def register_renderer(name, &block)
        self.instance.register_renderer(name, &block)
      end

      # Parses a source text.
      #
      # @param content [String] The content to parse.
      # @param options [Hash] A list of options for parsing.
      # @return [Content] The parsed data.
      def parse(content, options = {})
        self.instance.parser(content, options)
      end

      # Renders a content.
      #
      # @param content [Content] The content to parse.
      # @param renderer [StringSymbol] T
      def render(content, renderer = :html_pipeline, options = {}, context = {})
        self.instance.render(content, renderer, options, context)
      end

      # Returns a unique (singleton) instance of the parser.
      #
      # @param force [Boolean] If to force recreation of the instance.
      # @return [Parser] The unique (singleton) instance of the parser.
      def instance(force = false)
        @instance = nil if force
        @instance ||= Mbrao::Parser.new
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
            (http(s?):\/\/) #PROTOCOL
            (([\w-]+\.)?) # LOWEST TLD
            ([\w-]+) # 2nd LEVEL TLD
            (\.[a-z]+) # TOP TLD
            ((:\d+)?) # PORT
            ([\S|\?]*) # PATH, QUERYSTRING AND FRAGMENT
          )$
        /ix

        text.ensure_string.strip =~ regex
      end

      # Convert an object making sure that every `Hash` is converted to a `HashWithIndifferentAccess`.
      #
      # @param object [Object] The object to convert. If the object is not an Hash or doesn't respond to `collect` then the original object is returned..
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

      # Convert an object to a a flatten array with all values sanitize.
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
        # Sanitizies an value for an hash.
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

    def parse(content, options = {})
      # TODO
    end

    def render(content, renderer, options = {}, context = {})
      # TODO
    end

    def register_renderer(name, &block)
      # TODO
    end
  end
end