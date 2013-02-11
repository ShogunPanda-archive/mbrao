# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::Author do
  describe "#initialize" do
    it "create a new object" do
      reference = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(reference.name).to eq("NAME")
      expect(reference.email).to eq("name@example.com")
      expect(reference.website).to eq("http://example.com")
      expect(reference.image).to eq("http://example.com/image.jpg")
      expect(reference.metadata).to eq({"a" => {"b" => :c}})
    end

    it "make sure that email is valid" do
      reference = Mbrao::Author.new("NAME", "INVALID", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(reference.email).to be_nil
    end

    it "make sure that website is a valid URL" do
      reference = Mbrao::Author.new("NAME", "name@example.com", "INVALID", "http://example.com/image.jpg", {a: {b: :c}})
      expect(reference.website).to be_nil
    end

    it "make sure that image is a valid URL" do
      reference = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "INVALID", {a: {b: :c}})
      expect(reference.image).to be_nil
    end

    it "make sure that hash is a recursively a HashWithIndifferentAccess" do
      reference = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(reference.metadata).to be_a(HashWithIndifferentAccess)
      expect(reference.metadata["a"]).to be_a(HashWithIndifferentAccess)
    end
  end
end