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

    it "should assign contents" do
      created_at = DateTime.civil(1984, 7, 7, 11, 30, 0)
      metadata = {uid: "UID", title: {it: "IT", en: "EN"}, author: "AUTHOR", tags: {it: "IT", en: "EN"}, more: "MORE", created_at: created_at, locales: ["it", ["en"]], other: ["OTHER"]}

      reference.should_receive(:separate_components).with("CONTENT", {a: "b"}).and_return([metadata, "BODY"])
      reference.stub(:parse_metadata).with(metadata, {a: "b"}).and_return(metadata)
      content = reference.parse("CONTENT", {a: "b"})
      expect(content.uid).to eq("UID")
      expect(content.title).to eq({"it" => "IT", "en" => "EN"})
      expect(content.author).to be_a(::Mbrao::Author)
      expect(content.author.name).to eq("AUTHOR")
      expect(content.body).to eq("BODY")
      expect(content.tags).to eq({"it" => ["IT"], "en" => ["EN"]})
      expect(content.more).to eq("MORE")
      expect(content.created_at).to eq(created_at)
      expect(content.updated_at).to eq(created_at)
      expect(content.locales).to eq(["it", "en"])
      expect(content.metadata).to eq({"other" => ["OTHER"]})
    end
  end
end