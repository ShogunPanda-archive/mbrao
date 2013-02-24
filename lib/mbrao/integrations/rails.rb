# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# TODO: Support for Rails streaming
# TODO: Understand why the template is not correctly reported in backtraces.

if defined?(ActionView) then
  # Generic interface to mulsdtiple Ruby template engines.
  module ActionView::Template::Handlers
    # Class for rendering mbrao contents in Rails.
    class MbraoTemplate
      # Method called to render a template.
      #
      # @param template [ActionView::Template] The template to render.
      # @return [String] A Ruby snippet to execute to render the template.
      def self.call(template)
        "ActionView::Template::Handlers::MbraoTemplate.render(self, #{template.source.to_json})"
      end

      # Renders a template into a renderer context.
      #
      # @param renderer [Object] The renderer context.
      # @param template [String] The template to render.
      # @return [String] The rendered template.
      def self.render(renderer, template)
        content = ::Mbrao::Parser.parse(template)
        renderer.controller.instance_variable_set(:@mbrao_content, content)
        renderer.controller.define_singleton_method(:mbrao_content) { @mbrao_content }

        ::Mbrao::Parser.render(content, {engine: content.metadata[:engine], locale: renderer.controller.params[:locale]})
      end
    end
  end

  ActionView::Template.register_template_handler "emt", ActionView::Template::Handlers::MbraoTemplate if defined?(ActionView) && defined?(Rails) && Rails.version =~ /^[34]/
end

