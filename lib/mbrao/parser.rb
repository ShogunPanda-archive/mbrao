# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

# A content parser and renderer with embedded metadata support.
module Mbrao
  # A parser to handle pipelined content.
  #
  class Parser
    include Mbrao::ParserInterface
    include Mbrao::ParserValidations

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

    # :nodoc:
    def sanitize_parsing_options(options)
      options = options.ensure_hash(accesses: :symbols)

      options[:engine] ||= Mbrao::Parser.parsing_engine
      options[:metadata] = options.fetch(:metadata, true).to_boolean
      options[:content] = options.fetch(:content, true).to_boolean

      HashWithIndifferentAccess.new(options)
    end

    # :nodoc:
    def sanitize_rendering_options(options)
      options = options.ensure_hash(accesses: :symbols)

      options[:engine] ||= Mbrao::Parser.rendering_engine

      HashWithIndifferentAccess.new(options)
    end
  end
end
