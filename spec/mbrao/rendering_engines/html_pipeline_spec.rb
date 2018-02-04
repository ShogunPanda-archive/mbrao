# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Mbrao::RenderingEngines::HtmlPipeline do
  subject{ Mbrao::RenderingEngines::HtmlPipeline.new }

  describe "#render" do
    it "should forward everything to the html-pipeline" do
      pipeline = Object.new
      expect(pipeline).to receive(:call).with("CONTENT").and_return({output: ""})
      expect(::HTML::Pipeline).to receive(:new).with(an_instance_of(Array), an_instance_of(Hash)).and_return(pipeline)
      subject.render("CONTENT")
    end

    it "should raise a specific exception if a locale is not available" do
      expect { subject.render(::Mbrao::Content.create({locales: ["en"]}, "BODY"), {locales: ["it"]}) }.to raise_error(::Mbrao::Exceptions::UnavailableLocalization)
    end

      it "should raise an exception if anything goes wrong" do
      allow(::HTML::Pipeline).to receive(:new).and_raise(ArgumentError.new("ERROR"))
      expect { subject.render("CONTENT") }.to raise_error(::Mbrao::Exceptions::Rendering)
    end

    it "should have default options" do
      filters = [:kramdown, :table_of_contents, :autolink, :emoji, :image_max_width].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, {gfm: true, asset_root: "/"}).and_call_original
      subject.render("CONTENT")
    end

    it "should merge context to options" do
      expect(::HTML::Pipeline).to receive(:new).with(an_instance_of(Array), {gfm: true, asset_root: "/", additional: true}).and_call_original
      subject.render("CONTENT", {}, {additional: true})
    end

    it "should restrict filter used" do
      filters = [:table_of_contents, :autolink, :emoji, :image_max_width].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      subject.render("CONTENT", {kramdown: false})

      filters = [:kramdown, :autolink, :emoji, :image_max_width].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      subject.render("CONTENT", {toc: false})

      filters = [:kramdown, :table_of_contents, :emoji, :image_max_width].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      subject.render("CONTENT", {links: false})

      filters = [:kramdown, :table_of_contents, :autolink, :image_max_width].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      subject.render("CONTENT", {emoji: false})

      filters = [:kramdown, :table_of_contents, :autolink, :emoji].map {|f| ::Lazier.find_class(f, "::HTML::Pipeline::%CLASS%Filter", true) }
      expect(::HTML::Pipeline).to receive(:new).with(filters, an_instance_of(Hash)).and_call_original
      subject.render("CONTENT", {image_max_width: false})
    end
  end

  describe "#default_pipeline" do
    it "should return a default pipeline" do
      expect(subject.default_pipeline).to eq([[:kramdown], [:table_of_contents, :toc], [:autolink, :links], [:emoji], [:image_max_width]])
    end
  end

  describe "#default_pipeline=" do
    it "should set a correct pipeline" do
      subject.default_pipeline = nil
      expect(subject.default_pipeline).to eq([])

      subject.default_pipeline = "A"
      expect(subject.default_pipeline).to eq([[:A]])

      subject.default_pipeline = ["A", "B"]
      expect(subject.default_pipeline).to eq([[:A], [:B]])

      subject.default_pipeline = ["1", [["B", ["C"]]]]
      expect(subject.default_pipeline).to eq([[:"1"], [:B, :C]])
    end
  end

  describe "#default_options" do
    it "should return a default hash" do
      expect(subject.default_options).to eq({gfm: true, asset_root: "/"})
    end

    it "should return the set hash" do
      subject.instance_variable_set(:@default_options, {})
      expect(subject.default_options).to eq({})
    end
  end

  describe "#default_options=" do
    it "should only assign if the value is an Hash" do
      subject.default_options = {a: "b"}
      expect(subject.default_options).to eq({a: "b"})
      subject.default_options = 1
      expect(subject.default_options).to eq({})
      subject.default_options = nil
      expect(subject.default_options).to eq({})
    end
  end
end