# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::ParsingEngines::Base do
  let(:reference) { Mbrao::ParsingEngines::Base.new }

  shared_examples_for("unimplemented") do |method|
    it "should raise an exception" do
      expect { reference.send(method, "CONTENT", {}) }.to raise_error(Mbrao::Exceptions::Unimplemented)
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
    let(:reference) { ::Mbrao::ParsingEngines::Base.new }

    it "should forward to ::Mbrao::Content.create" do
      reference.should_receive(:separate_components).with("CONTENT", {a: "b"}).and_return([{a: "b"}, "BODY"])
      reference.stub(:parse_metadata).and_return({a: "b"})
      ::Mbrao::Content.should_receive(:create).with({a: "b"}, "BODY")
      reference.parse("CONTENT", {a: "b"})
    end

    it "should return a Content object" do
      reference.stub(:separate_components).with("CONTENT", {a: "b"}).and_return([])
      reference.stub(:parse_metadata).and_return({})
      expect(reference.parse("CONTENT", {a: "b"})).to be_a(::Mbrao::Content)
    end

    it "should separate_components" do
      reference.should_receive(:separate_components).with("CONTENT", {a: "b"})
      reference.stub(:parse_metadata).and_return({})
      reference.parse("CONTENT", {a: "b"})
    end
  end
end