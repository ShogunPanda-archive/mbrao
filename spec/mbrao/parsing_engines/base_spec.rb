# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Mbrao::ParsingEngines::Base do
  subject{ Mbrao::ParsingEngines::Base.new }

  shared_examples_for("unimplemented") do |method|
    it "should raise an exception" do
      expect { subject.send(method, "CONTENT", {}) }.to raise_error(Mbrao::Exceptions::Unimplemented)
    end
  end

  describe "#separate_components" do
    it_should_behave_like "unimplemented", :separate_components
  end

  describe "#parse_metadata" do
    it_should_behave_like "unimplemented", :parse_metadata
  end

  describe "#filter_content" do
    it_should_behave_like "unimplemented", :filter_content
  end

  describe "#parse" do
    subject{ ::Mbrao::ParsingEngines::Base.new }

    it "should forward to ::Mbrao::Content.create" do
      expect(subject).to receive(:separate_components).with("CONTENT", {a: "b"}).and_return([{a: "b"}, "BODY"])
      allow(subject).to receive(:parse_metadata).and_return({a: "b"})
      expect(::Mbrao::Content).to receive(:create).with({a: "b"}, "BODY")
      subject.parse("CONTENT", {a: "b"})
    end

    it "should return a Content object" do
      allow(subject).to receive(:separate_components).with("CONTENT", {a: "b"}).and_return([])
      allow(subject).to receive(:parse_metadata).and_return({})
      expect(subject.parse("CONTENT", {a: "b"})).to be_a(::Mbrao::Content)
    end

    it "should separate_components" do
      expect(subject).to receive(:separate_components).with("CONTENT", {a: "b"})
      allow(subject).to receive(:parse_metadata).and_return({})
      subject.parse("CONTENT", {a: "b"})
    end
  end
end