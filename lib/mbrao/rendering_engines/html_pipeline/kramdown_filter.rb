# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
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
