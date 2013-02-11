# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::Content do
  let(:reference) { Mbrao::Content.new("UID") }

  describe "#initialize" do
    it "store the uid" do
      reference = Mbrao::Content.new("SAMPLE")
      expect(reference.uid).to eq("SAMPLE")
    end
  end

  describe "#locales=" do
    it "correctly assign a string, a symbol or an array" do
      reference.locales = :it
      expect(reference.locales).to eq(["it"])
      reference.locales = "en"
      expect(reference.locales).to eq(["en"])
      reference.locales = ["en", [:it, :es]]
      expect(reference.locales).to eq(["en", "it", "es"])
    end
  end

  describe "#title=" do

  end

  describe "#body" do

  end

  describe "#tags" do

  end

  describe "#more" do

  end

  describe "#author" do

  end

  describe "#created_at" do

  end

  describe "#updated_at" do

  end

  describe "#metadata" do

  end

  describe "#enabled_for_locales?" do

  end

  describe "#get_title" do

  end

  describe "#get_body" do

  end

  describe "#get_tags" do

  end

  describe "#get_more" do

  end
end