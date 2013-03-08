# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Generic interface to multiple Ruby template engines.
module ActionView::Template::Handlers
  # Class for rendering mbrao contents in Rails.
  class MbraoTemplate
    # Returns a unique (singleton) instance of the template handler.
    #
    # @param force [Boolean] If to force recreation of the instance.
    # @return [MbraoTemplate] The unique (singleton) instance of the template handler.
    def self.instance(force = false)
      @instance = nil if force
      @instance ||= ActionView::Template::Handlers::MbraoTemplate.new
    end

    # Renders a template into a renderer context.
    #
    # @param renderer [Object] The renderer context.
    # @param template [String] The template to render.
    # @return [String] The rendered template.
    def render(renderer, template)
      content = ::Mbrao::Parser.parse(template)
      renderer.controller.instance_variable_set(:@mbrao_content, content)
      renderer.controller.define_singleton_method(:mbrao_content) { @mbrao_content }
      renderer.controller.class.send(:helper_method, :mbrao_content)

      ::Mbrao::Parser.render(content, {engine: content.metadata[:engine], locale: renderer.controller.params[:locale]})
    end

    # Declares support for streaming.
    #
    # @return [TrueClass] Declares support for streaming.
    def supports_streaming?
      true
    end

    # Method called to render a template.
    #
    # @param template [ActionView::Template] The template to render.
    # @return [String] A Ruby snippet to execute to render the template.
    def call(template)
      "ActionView::Template::Handlers::MbraoTemplate.instance.render(self, #{template.source.to_json})"
    end
  end
end

ActionView::Template.register_template_handler "emt", ActionView::Template::Handlers::MbraoTemplate.instance if defined?(ActionView) && defined?(Rails) && Rails.version =~ /^[34]/