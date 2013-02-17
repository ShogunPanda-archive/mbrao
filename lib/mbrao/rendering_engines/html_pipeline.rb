# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # Engines used to render contents with metadata.
  module RenderingEngines
    # A renders which use the {html-pipeline https://github.com/jch/html-pipeline} gem.
    class HtmlPipeline
      # TODO: Support for kramdown.

      # Renders a content.
      #
      # @param content [Content] The content to parse.
      # @param options [Hash] A list of options for renderer.
      # @param context [Hash] A context for rendering.
      def render(content, options = {}, context = {})
        rv = ""
        options = sanitize_options(options)
        context = contenxt.is_a?(Hash) ? context.symbolize_keys : {}

        begin
          ::HTML::Pipeline.new(options[:pipeline].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter") }, options[:pipeline_options]).call(content)
        rescue Exception => e
          raise ::Mbrao::Exceptions::Rendering.new(e.to_s)
        end
      end

      private
        # Sanitizes options.
        #
        # @param options [Hash] The options to sanitize.
        # @return [Hash] The sanitized options.
        def sanitize_options(options)
          default_pipeline = [:markdown, :syntax_highlight, :table_of_contents, :auto_link, :emoji, :image_max_width]
          default_options = {:gfm => true}

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
          options[:pipeline] = options.fetch(:pipeline, default_pipeline).collect(&:to_sym)

          [[:highlight, :syntax_highlight], [:toc, :table_of_contents], [:links, :auto_link], [:emoji]].each do |f|
            options[:pipeline].delete(f.last) if !options.fetch(f.first, true)
          end

          options
        end
    end
  end
end