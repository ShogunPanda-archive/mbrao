# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

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
      ActionView::Template::Handlers::MbraoTemplate.should_not_receive(:new)
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
      renderer.stub(:controller).and_return(controller)

      expect(controller.respond_to?(:mbrao_content)).to be_false
      ::Mbrao::Parser.should_receive(:parse).and_call_original
      ActionView::Template::Handlers::MbraoTemplate.instance.render(renderer, "CONTENT")

      expect(controller.respond_to?(:mbrao_content)).to be_true
      expect(controller.mbrao_content.body).to eq("CONTENT")
    end

    it "should render contents, using specified engine and locale" do
      controller = DummyController.new
      renderer = DummyRenderer.new
      renderer.stub(:controller).and_return(controller)

      content = ::Mbrao::Content.create({engine: "ENGINE"}, "CONTENT")
      ::Mbrao::Parser.stub(:parse).and_return(content)

      ::Mbrao::Parser.should_receive(:render).with(content, {engine: "ENGINE", locale: "LOCALE"})
      ActionView::Template::Handlers::MbraoTemplate.instance.render(DummyRenderer.new, "CONTENT")
    end
  end

  describe "#supports_streaming?" do
    it "should be true" do
      expect(ActionView::Template::Handlers::MbraoTemplate.instance.supports_streaming?).to be_true
    end
  end
end