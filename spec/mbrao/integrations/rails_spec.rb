# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"
require "action_view"
require "mbrao/integrations/rails"

describe ActionView::Template::Handlers::MbraoTemplate do
  class DummyTemplate
    def initialize(content)
      @content = content
    end

    def source
      @content
    end
  end

  class DummyController
    def params
      {locale: "LOCALE"}
    end

    def self.helper_method(_)
    end
  end

  class DummyRenderer
    def controller
      @controller ||= DummyController.new
    end
  end

  describe ".instance" do
    it "should create a new instance" do
      expect(ActionView::Template::Handlers::MbraoTemplate.instance).to be_a(ActionView::Template::Handlers::MbraoTemplate)
    end

    it "should always return the same instance" do
      other = ActionView::Template::Handlers::MbraoTemplate.instance
      expect(ActionView::Template::Handlers::MbraoTemplate).not_to receive(:new)
      expect(ActionView::Template::Handlers::MbraoTemplate.instance).to eq(other)
    end

    it "should recreate an instance" do
      other = ActionView::Template::Handlers::MbraoTemplate.instance
      expect(ActionView::Template::Handlers::MbraoTemplate.instance(true)).not_to eq(other)
    end
  end


  describe "#call" do
    it "should return a Ruby snippet" do
      expect(ActionView::Template::Handlers::MbraoTemplate.instance.call(DummyTemplate.new("CONTENT"))).to eq("ActionView::Template::Handlers::MbraoTemplate.instance.render(self, \"CONTENT\")")
    end
  end

  describe "#render" do
    it "should initialize a Content and assign it to the controller" do
      controller = DummyController.new
      renderer = DummyRenderer.new
      allow(renderer).to receive(:controller).and_return(controller)

      expect(controller.respond_to?(:mbrao_content)).to be_false
      expect(::Mbrao::Parser).to receive(:parse).and_call_original
      expect(controller.class).to receive(:helper_method).with(:mbrao_content)
      ActionView::Template::Handlers::MbraoTemplate.instance.render(renderer, "CONTENT")

      expect(controller.respond_to?(:mbrao_content)).to be_true
      expect(controller.mbrao_content.body).to eq("CONTENT")
    end

    it "should render contents, using specified engine and locale" do
      controller = DummyController.new
      renderer = DummyRenderer.new
      allow(renderer).to receive(:controller).and_return(controller)

      content = ::Mbrao::Content.create({engine: "ENGINE"}, "CONTENT")
      allow(::Mbrao::Parser).to receive(:parse).and_return(content)

      expect(::Mbrao::Parser).to receive(:render).with(content, {engine: "ENGINE", locale: "LOCALE"})
      ActionView::Template::Handlers::MbraoTemplate.instance.render(DummyRenderer.new, "CONTENT")
    end
  end

  describe "#supports_streaming?" do
    it "should be true" do
      expect(ActionView::Template::Handlers::MbraoTemplate.instance.supports_streaming?).to be_true
    end
  end
end