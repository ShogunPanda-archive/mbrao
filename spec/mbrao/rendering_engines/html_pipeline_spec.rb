# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::RenderingEngines::HtmlPipeline do
  let(:reference) { Mbrao::RenderingEngines::HtmlPipeline.new }

  describe "#render" do
    it "should forward everything to the html-pipeline" do
      pipeline = Object.new
      pipeline.should_receive(:call).with("CONTENT")
      ::HTML::Pipeline.should_receive(:new).with(an_instance_of(Array), an_instance_of(Hash)).and_return(pipeline)
      reference.render("CONTENT")
    end

    it "should raise an exception if anything goes wrong" do
      ::HTML::Pipeline.stub(:new).and_raise(ArgumentError.new("ERROR"))
      expect { reference.render("CONTENT") }.to raise_error(::Mbrao::Exceptions::Rendering)
    end

    it "should have default options" do
      filters = [:markdown, :table_of_contents, :autolink, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, {gfm: true, asset_root: "/"}).and_call_original
      reference.render("CONTENT")
    end

    it "should merge context to options" do
      ::HTML::Pipeline.should_receive(:new).with(an_instance_of(Array), {gfm: true, asset_root: "/", additional: true}).and_call_original
      reference.render("CONTENT", {}, {additional: true})
    end

    it "should restrict filter used" do
      filters = [:table_of_contents, :autolink, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {markdown: false})

      filters = [:markdown, :autolink, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {toc: false})

      filters = [:markdown, :table_of_contents, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {links: false})

      filters = [:markdown, :table_of_contents, :autolink, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {emoji: false})

      filters = [:markdown, :table_of_contents, :autolink, :emoji].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {image_max_width: false})
    end
  end

  describe "#default_pipeline" do
    it "should return a default pipeline" do
      expect(reference.default_pipeline).to eq([[:markdown], [:table_of_contents, :toc], [:autolink, :links], [:emoji], [:image_max_width]])
    end
  end

  describe "#default_pipeline=" do
    it "should set a correct pipeline" do
      reference.default_pipeline = nil
      expect(reference.default_pipeline).to eq([[]])

      reference.default_pipeline = "A"
      expect(reference.default_pipeline).to eq([[:A]])

      reference.default_pipeline = ["A", "B"]
      expect(reference.default_pipeline).to eq([[:A], [:B]])

      reference.default_pipeline = ["1", [["B", ["C"]]]]
      expect(reference.default_pipeline).to eq([[:"1"], [:B, :C]])
    end
  end
end