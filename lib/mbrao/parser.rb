# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A pipelined content parser with metadata support.
module Mbrao
  # Methods to allow class level access.
  module PublicInterface
    extend ActiveSupport::Concern

    # Class methods.
    module ClassMethods
      def register_renderer(name, &block)
        self.instance.register_renderer(name, &block)
      end

      def parse(content, options = {})
        self.instance.parser(content, options)
      end

      def render(content, renderer, options = {}, context = {})
        self.instance.render(content, renderer, options = {}, context = {})
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
      # @return [Object] The converted object.
      def ensure_safe_hash(object)
        if object.is_a?(Hash) || object.is_a?(HashWithIndifferentAccess) then
          object.inject(HashWithIndifferentAccess.new) do |hash, pair|
            hash[pair[0]] = Mbrao::Parser.ensure_safe_hash(pair[1])
            hash
          end
        elsif object.respond_to?(:collect) then
          object.collect {|item| Mbrao::Parser.ensure_safe_hash(item) }
        else
          object
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