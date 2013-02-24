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
      pipeline.should_receive(:call).with("CONTENT").and_return({output: ""})
      ::HTML::Pipeline.should_receive(:new).with(an_instance_of(Array), an_instance_of(Hash)).and_return(pipeline)
      reference.render("CONTENT")
    end

    it "should raise an exception if anything goes wrong" do
      ::HTML::Pipeline.stub(:new).and_raise(ArgumentError.new("ERROR"))
      expect { reference.render("CONTENT") }.to raise_error(::Mbrao::Exceptions::Rendering)
    end

    it "should have default options" do
      filters = [:kramdown, :table_of_contents, :autolink, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
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
      reference.render("CONTENT", {kramdown: false})

      filters = [:kramdown, :autolink, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {toc: false})

      filters = [:kramdown, :table_of_contents, :emoji, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {links: false})

      filters = [:kramdown, :table_of_contents, :autolink, :image_max_width].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {emoji: false})

      filters = [:kramdown, :table_of_contents, :autolink, :emoji].collect {|f| ::Mbrao::Parser.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      ::HTML::Pipeline.should_receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      reference.render("CONTENT", {image_max_width: false})
    end
  end

  describe "#default_pipeline" do
    it "should return a default pipeline" do
      expect(reference.default_pipeline).to eq([[:kramdown], [:table_of_contents, :toc], [:autolink, :links], [:emoji], [:image_max_width]])
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

  describe "#default_options" do
    it "should return a default hash" do
      expect(reference.default_options).to eq({gfm: true, asset_root: "/"})
    end

    it "should return the set hash" do
      reference.instance_variable_set(:@default_options, {})
      expect(reference.default_options).to eq({})
    end
  end

  describe "#default_options=" do
    it "should only assign if the value is an Hash" do
      reference.default_options = {a: "b"}
      expect(reference.default_options).to eq({a: "b"})
      reference.default_options = 1
      expect(reference.default_options).to eq({})
      reference.default_options = nil
      expect(reference.default_options).to eq({})
    end
  end
end

describe HTML::Pipeline::KramdownFilter do
  describe "#initialize" do
    it "should call the parent constructor" do
      HTML::Pipeline::TextFilter.should_receive(:new).with("\rCONTENT\r", {a: "b"}, {c: "d"})
      HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"})
    end

    it "should remove \r from the text" do
      reference = HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"})
      expect(reference.instance_variable_get(:@text)).to eq("CONTENT")
    end

    it "should use Kramdown with given options for building the result" do
      object = Object.new
      Kramdown::Document.should_receive(:new).with("CONTENT", {a: "b"}).and_return(object)
      object.should_receive(:to_html)
      HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"}).call
    end
  end
end