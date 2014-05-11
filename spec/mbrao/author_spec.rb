# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::Author do
  describe ".create" do
    it "creates a author from a non-hash" do
      expect(Mbrao::Author).to receive(:new).with("NAME")
      Mbrao::Author.create("NAME")

      expect(Mbrao::Author).to receive(:new).with(nil)
      Mbrao::Author.create(nil)

      expect(Mbrao::Author).to receive(:new).with([])
      Mbrao::Author.create([])

      expect(Mbrao::Author).to receive(:new).with(["NAME"])
      Mbrao::Author.create(["NAME"])
    end

    it "creates a author from a hash" do
      expect(Mbrao::Author).to receive(:new).with("NAME", "EMAIL", "WEBSITE", "IMAGE", {"other" => "OTHER"}).and_call_original
      expect_any_instance_of(Mbrao::Author).to receive("uid=").with("UID")
      Mbrao::Author.create({name: "NAME", email: "EMAIL", website: "WEBSITE", image: "IMAGE", other: "OTHER", uid: "UID"})
    end
  end

  describe "#initialize" do
    it "create a new object" do
      subject = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(subject.name).to eq("NAME")
      expect(subject.email).to eq("name@example.com")
      expect(subject.website).to eq("http://example.com")
      expect(subject.image).to eq("http://example.com/image.jpg")
      expect(subject.metadata).to eq({"a" => {"b" => :c}})
    end

    it "make sure that email is valid" do
      subject = Mbrao::Author.new("NAME", "INVALID", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(subject.email).to be_nil
    end

    it "make sure that website is a valid URL" do
      subject = Mbrao::Author.new("NAME", "name@example.com", "INVALID", "http://example.com/image.jpg", {a: {b: :c}})
      expect(subject.website).to be_nil
    end

    it "make sure that image is a valid URL" do
      subject = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "INVALID", {a: {b: :c}})
      expect(subject.image).to be_nil
    end

    it "make sure that hash is a recursively a HashWithIndifferentAccess" do
      subject = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})
      expect(subject.metadata).to be_a(HashWithIndifferentAccess)
      expect(subject.metadata["a"]).to be_a(HashWithIndifferentAccess)
    end
  end

  describe "#as_json" do
    it "should return the content as a JSON hash" do
      subject = Mbrao::Author.new("NAME", "name@example.com", "http://example.com", "http://example.com/image.jpg", {a: {b: :c}})

      expect(subject.as_json).to eq({
        "email" => "name@example.com",
        "image" => "http://example.com/image.jpg",
        "metadata" => {"a" => {"b" => "c"}},
        "name" => "NAME",
        "uid" => nil,
        "website" => "http://example.com"
      })
    end
  end
end