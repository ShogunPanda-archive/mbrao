# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Mbrao
  # Engines used to render contents with metadata.
  module RenderingEngines
    # A renders which use the [html-pipeline](https://github.com/jch/html-pipeline) gem.
    #
    # @attribute default_pipeline
    #   @return [Array] The default pipeline to use. It should be an array of pairs of `Symbol`, which the first element is the filter (in underscored version
    #     and without the filter suffix) and the second is a shortcut to disable the pipeline via options.
    #     You can also specify a single element to disable shortcuts.
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
        context = context.ensure_hash(accesses: :symbols)

        begin
          create_pipeline(options, context).call(get_body(content, options))[:output].to_s
        rescue Mbrao::Exceptions::UnavailableLocalization => le
          raise le
        rescue => e
          raise ::Mbrao::Exceptions::Rendering, e.to_s
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
        @default_pipeline = value.ensure_array { |v| v.ensure_array(no_duplicates: true, compact: true, flatten: true) { |p| p.ensure_string.to_sym } }
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

      # :nodoc:
      def sanitize_options(options)
        options = options.ensure_hash(accesses: :symbols)
        options = filter_filters(options)
        options[:pipeline_options] = default_options.merge(options[:pipeline_options].ensure_hash(accesses: :symbols))

        options
      end

      # :nodoc:
      def get_body(content, options)
        content = ::Mbrao::Content.create(nil, content.ensure_string) unless content.is_a?(::Mbrao::Content)
        content.get_body(options.fetch(:locales, ::Mbrao::Parser.locale).ensure_string)
      end

      # :nodoc:
      def create_pipeline(options, context)
        ::HTML::Pipeline.new(
          options[:pipeline].map { |f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) },
          options[:pipeline_options].merge(context)
        )
      end

      # :nodoc:
      def filter_filters(options)
        options[:pipeline] = get_pipeline(options)

        default_pipeline.each do |f|
          options[:pipeline].delete(f.first) unless options.fetch(f.last, true)
        end

        options
      end

      # :nodoc:
      def get_pipeline(options)
        options.fetch(:pipeline, default_pipeline.map(&:first)).map(&:to_sym)
      end
    end
  end
end
