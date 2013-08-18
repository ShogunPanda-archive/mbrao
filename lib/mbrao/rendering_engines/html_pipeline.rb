# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Main module of the [html-pipeline](https://github.com/jch/html-pipeline) gem.
module HTML
  # A [html-pipeline](https://github.com/jch/html-pipeline) gem Pipeline.
  class Pipeline
    # A filter to compile Markdown contents.
    class KramdownFilter < TextFilter
      # Creates a new filter.
      #
      # @param text [String] The string to convert.
      # @param context [Hash] The context of the conversion.
      # @param result [Hash] A result hash.
      def initialize(text, context = nil, result = nil)
        super(text, context, result)
        @text = @text.gsub("\r", "")
      end

      # Converts Markdown to HTML using Kramdown and converts into a DocumentFragment.
      #
      # @return [DocumentFragment] The converted fragment.
      def call
        Kramdown::Document.new(@text, @context).to_html
      end
    end
  end
end

module Mbrao
  # Engines used to render contents with metadata.
  module RenderingEngines
    # A renders which use the [html-pipeline](https://github.com/jch/html-pipeline) gem.
    #
    # @attribute default_pipeline
    #   @return [Array] The default pipeline to use. It should be an array of pairs of `Symbol`, which the first element is the filter (in underscored version and without the filter suffix) and the second is a shortcut to disable the pipeline via options. You can also specify a single element to disable shortcuts.
    # @attribute default_options
    #   @return [Hash] The default options for the renderer.
    class HtmlPipeline < Mbrao::RenderingEngines::Base
      attr_accessor :default_pipeline
      attr_accessor :default_options

      # Renders a content.
      #
      # @param content [Content|String] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      def render(content, options = {}, context = {})
        options = sanitize_options(options)
        context = context.ensure_hash(:symbols)

        begin
          create_pipeline(options, context).call(get_body(content, options))[:output].to_s
        rescue Mbrao::Exceptions::UnavailableLocalization => le
          raise le
        rescue => e
          raise ::Mbrao::Exceptions::Rendering.new(e.to_s)
        end
      end

      # Gets the default pipeline.
      #
      # @return [Array] The default pipeline.
      def default_pipeline
        @default_pipeline || [[:kramdown], [:table_of_contents, :toc], [:autolink, :links], [:emoji], [:image_max_width]]
      end

      # Sets the default pipeline.
      #
      # @return [Array] The default pipeline.
      def default_pipeline=(value)
        @default_pipeline = value.ensure_array(nil, false, false) {|v| v.ensure_array(nil, true, true, true) { |p| p.ensure_string.to_sym } }
      end

      # Gets the default options.
      #
      # @return [Hash] The default options.
      def default_options
        @default_options || {gfm: true, asset_root: "/"}
      end

      # Sets the default options.
      #
      # @param value [Object] The new default options.
      def default_options=(value)
        @default_options = value.ensure_hash
      end

      private
        # Sanitizes options.
        #
        # @param options [Hash] The options to sanitize.
        # @return [Hash] The sanitized options.
        def sanitize_options(options)
          options = options.ensure_hash(:symbols)
          options = filter_filters(options)
          options[:pipeline_options] = self.default_options.merge(options[:pipeline_options].ensure_hash(:symbols))

          options
        end

        # Get body of a content.
        #
        # @param content [Content|String] The content to sanitize.
        # @param options [Hash] A list of options for renderer.
        # @return [Array] The body to parse.
        def get_body(content, options)
          content = ::Mbrao::Content.create(nil, content.ensure_string) if !content.is_a?(::Mbrao::Content)
          content.get_body(options.fetch(:locale, ::Mbrao::Parser.locale).ensure_string)
        end

        # Creates the pipeline for rendering.
        #
        # @param options [Hash] A list of options for renderer.
        # @param context [Hash] A context for rendering.
        # @return [HTML::Pipeline] The pipeline
        def create_pipeline(options, context)
          ::HTML::Pipeline.new(options[:pipeline].collect {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }, options[:pipeline_options].merge(context))
        end

        # Filters pipeline filters basing on the options provided.
        #
        # @param options [Hash] The original options.
        # @return [Hash] The options with the new set of filters.
        def filter_filters(options)
          options[:pipeline] = get_pipeline(options)

          self.default_pipeline.each do |f|
            options[:pipeline].delete(f.first) if !options.fetch(f.last, true)
          end

          options
        end

        # Gets the pipeline for the current options.
        #
        # @param options [Hash] The options to parse.
        # @return [Array] The pipeline to process.
        def get_pipeline(options)
          options.fetch(:pipeline, self.default_pipeline.collect(&:first)).collect(&:to_sym)
        end
    end
  end
end