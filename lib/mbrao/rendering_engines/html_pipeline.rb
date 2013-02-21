# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Engines used to render contents with metadata.
  module RenderingEngines
    # A renders which use the {html-pipeline https://github.com/jch/html-pipeline} gem.
    #
    # @attribute default_pipeline.
    #   @return [Array] The default pipeline to use. It should be an array of pairs of `Symbol`, which the first element is the filter (in underscorized version and without the filter suffix) and the second is a shortcut to disable the pipeline via options. You can also specify a single element to disable shortcuts.
    class HtmlPipeline < Mbrao::RenderingEngines::Base
      attr_accessor :default_pipeline

      # TODO: Support for kramdown.
      # TODO: Support for oEmbed.

      # Renders a content.
      #
      # @param content [Content] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      def render(content, options = {}, context = {})
        options = sanitize_options(options)
        context = context.is_a?(Hash) ? context.symbolize_keys : {}

        begin
          ::HTML::Pipeline.new(options[:pipeline].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }, options[:pipeline_options].merge(context)).call(content)
        rescue Exception => e
          raise ::Mbrao::Exceptions::Rendering.new(e.to_s)
        end
      end

      # Gets the default pipeline
      #
      # @return [Array] The default pipeline
      def default_pipeline
        @default_pipeline || [[:markdown], [:table_of_contents, :toc], [:autolink, :links], [:emoji], [:image_max_width]]
      end

      # Sets the default pipeline
      #
      # @return [Array] The default pipeline
      def default_pipeline=(value)
        @default_pipeline = value.ensure_array.collect {|v| v.ensure_array.flatten.compact.collect { |p| p.ensure_string.to_sym } }
      end

      private
        # Sanitizes options.
        #
        # @param options [Hash] The options to sanitize.
        # @return [Hash] The sanitized options.
        def sanitize_options(options)
          default_options = {gfm: true, asset_root: "/"}

          options = options.is_a?(Hash) ? options.symbolize_keys : {}
          options = filter_filters(options)
          options[:pipeline_options] = default_options.merge((options[:pipeline_options].is_a?(Hash) ? options[:pipeline_options] : {}).symbolize_keys)

          options
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