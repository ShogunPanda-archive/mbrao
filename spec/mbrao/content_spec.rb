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

  shared_examples_for("localized setter") do |attribute|
    it "should assign a single string" do
      reference.send("#{attribute}=", "ABC")
      expect(reference.send(attribute)).to eq("ABC")
      reference.send("#{attribute}=", 1)
      expect(reference.send(attribute)).to eq("1")
      reference.send("#{attribute}=", nil)
      expect(reference.send(attribute)).to eq("")
    end

    it "should assign a string with locales and sanitized entries" do
      reference.send("#{attribute}=", {en: nil, es: "ABC", it: 1})
      value = reference.send(attribute)
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value["en"]).to eq("")
      expect(value[:es]).to eq("ABC")
      expect(value["it"]).to eq("1")
    end
  end

  shared_examples_for("localized getter") do |attribute, v1, v2|
    it "should raise an exception if not available for that locale" do
      reference.locales = [:en, :it, :es]
      reference.send("#{attribute}=", v1)
      expect { reference.send("get_#{attribute}", [:de, :it]) }.not_to raise_error(Mbrao::Exceptions::UnavailableLocalization)
      expect { reference.send("get_#{attribute}", [:de]) }.to raise_error(Mbrao::Exceptions::UnavailableLocalization)
    end

    it "should return the attribute itself if not localized" do
      reference.locales = [:en, :it, :es]
      reference.send("#{attribute}=", v1)
      expect(reference.send("get_#{attribute}", [:de, :it])).to eq(v1)
    end

    it "should return the default locale if no locales are specified" do
      Mbrao::Parser.locale = :it
      reference.send("#{attribute}=", {en: v1, it: v2})
      expect(reference.send("get_#{attribute}")).to eq(v2)
    end

    it "should return only the subset of valid and request locales" do
      Mbrao::Parser.locale = :it
      reference.send("#{attribute}=", {en: v1, it: v2, de: v1, es: v2})

      value = reference.send("get_#{attribute}", [:de, :es])
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value.keys).to eq(["de", "es"])

      value = reference.send("get_#{attribute}", [:it, :de, :pt, :fr])
      expect(value.keys.sort).to eq(["de", "it"])

      reference.locales = [:en, :it, :es]
      value = reference.send("get_#{attribute}", "*")
      expect(value.keys.sort).to eq(["de", "en", "es", "it"])

      reference.send("#{attribute}=", {en: v1, "it,es" => v2, " de,    fr " => v1})
      value = reference.send("get_#{attribute}", [:it, :fr])
      expect(value.keys.sort).to eq(["fr", "it"])
    end
  end

  shared_examples_for("date setter") do |attribute|
    it "should correctly parse a datetime classes" do
      reference.send("#{attribute}=", Date.civil(2012, 8, 8))
      value = reference.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T000000+0000")

      reference.send("#{attribute}=", DateTime.civil(2012, 8, 8, 11, 30, 45))
      value = reference.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T113045+0000")

      Time.zone = 'Europe/Rome'
      date = Time.at(1344421800)
      reference.send("#{attribute}=", date)
      value = reference.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103000+0000")
    end

    it "should correctly parse a timestamp" do
      reference.send("#{attribute}=", 1344421800)
      value = reference.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103000+0000")
    end

    it "should try to parse everything else as a ISO8601 format" do
      reference.send("#{attribute}=", "20120808T083000-0200")
      value = reference.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103000+0000")

      expect { reference.send("#{attribute}=", "ABC") }.to raise_error(Mbrao::Exceptions::InvalidDate)
      expect { reference.send("#{attribute}=", []) }.to raise_error(Mbrao::Exceptions::InvalidDate)
    end
  end

  describe "#title=" do
    it_should_behave_like "localized setter", :title
  end

  describe "#body=" do
    it "should set the content as string" do
      reference.body = "A"
      expect(reference.body).to eq("A")
      reference.body = 1
      expect(reference.body).to eq("1")
      reference.body = nil
      expect(reference.body).to eq("")
    end
  end

  describe "#tags=" do
    it "should assign a single value" do
      reference.tags = "ABC"
      expect(reference.tags).to eq(["ABC"])
      reference.tags = ["ABC", [1, nil]]
      expect(reference.tags).to eq(["ABC", "1"])
    end

    it "should assign values with locales and sanitized entries" do
      reference.tags = {en: nil, es: "ABC", it: [1, [2, 3]]}
      value = reference.tags
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value["en"]).to eq([])
      expect(value[:es]).to eq(["ABC"])
      expect(value["it"]).to eq(["1", "2", "3"])
    end
  end

  describe "#more=" do
    it_should_behave_like "localized setter", :more
  end

  describe "#author=" do
    it "should assign an existing author" do
      author = ::Mbrao::Author.new("NAME")
      reference.author = author
      expect(reference.author).to be(author)
    end

    it "should only assign a name" do
      reference.author = "NAME"
      expect(reference.author).to be_a(::Mbrao::Author)
      expect(reference.author.name).to eq("NAME")
    end

    it "should assign by an hash" do
      reference.author = {name: "NAME", email: "EMAIL@email.com", "website" => "http://WEBSITE.TLD", "image" => "http://IMAGE.TLD", metadata: {a: "b"}, uid: "UID"}
      expect(reference.author).to be_a(::Mbrao::Author)
      expect(reference.author.name).to eq("NAME")
      expect(reference.author.email).to eq("EMAIL@email.com")
      expect(reference.author.website).to eq("http://WEBSITE.TLD")
      expect(reference.author.image).to eq("http://IMAGE.TLD")
      expect(reference.author.metadata).to be_a(::HashWithIndifferentAccess)
      expect(reference.author.metadata["a"]).to eq("b")
      expect(reference.author.uid).to eq("UID")
    end
  end

  describe "#created_at=" do
    it_should_behave_like "date setter", :created_at
  end

  describe "#updated_at=" do
    it_should_behave_like "date setter", :updated_at
  end

  describe "#metadata=" do
    it "correctly set a non hash value" do
      reference.metadata = "RAW"
      expect(reference.metadata).to be_a(::HashWithIndifferentAccess)
      expect(reference.metadata["raw"]).to eq("RAW")
    end

    it "correctly set a hash value" do
      reference.metadata = {en: nil, es: "ABC", it: [1, [2, 3]]}
      expect(reference.metadata).to be_a(::HashWithIndifferentAccess)
      expect(reference.metadata["es"]).to eq("ABC")
    end
  end

  describe "#enabled_for_locales?" do
    it "correctly check availability for certain locales" do
      reference.locales = [:en, :it]
      expect(reference.enabled_for_locales?).to be_true
      expect(reference.enabled_for_locales?(:en)).to be_true
      expect(reference.enabled_for_locales?(:it, :es)).to be_true
      expect(reference.enabled_for_locales?(:es, :de)).to be_false
    end
  end

  describe "#get_title" do
    it_should_behave_like "localized getter", :title, "ABC", "123"
  end

  describe "#get_body" do
    it "should create a parsing engine and use it for filtering" do
      reference.body = "BODY"
      engine = ::Mbrao::ParsingEngines::Base.new
      engine.should_receive(:filter_content).with(reference, ["it", "en"])
      ::Mbrao::Parser.should_receive(:create_engine).with("ENGINE").and_return(engine)
      reference.get_body(["it", "en"], "ENGINE")
    end
  end

  describe "#get_tags" do
    it_should_behave_like "localized getter", :tags, ["ABC", "123"], ["1", "2", "3", "4"]
  end

  describe "#get_more" do
    it_should_behave_like "localized getter", :more, "ABC", "123"
  end

  describe ".create" do
    it "should return a Content object" do
      expect(::Mbrao::Content.create(nil, "BODY")).to be_a(::Mbrao::Content)
    end

    it "should assign the body" do
      expect(::Mbrao::Content.create(nil, "BODY").body).to eq("BODY")
    end

    it "should assign metadata if present" do
      created_at = DateTime.civil(1984, 7, 7, 11, 30, 0)
      metadata = {"uid" => "UID", "title" => {it: "IT", en: "EN"}, "author" => "AUTHOR", "tags" => {it: "IT", en: "EN"}, "more" => "MORE", created_at: created_at, locales: ["it", ["en"]], other: ["OTHER"]}
      content = ::Mbrao::Content.create(metadata, "BODY")

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

    it "should ignore invalid metadata" do
      expect(::Mbrao::Content.create(nil, "BODY").metadata).to eq({})
      expect(::Mbrao::Content.create(1, "BODY").metadata).to eq({})
      expect(::Mbrao::Content.create([], "BODY").metadata).to eq({})
      expect(::Mbrao::Content.create("A", "BODY").metadata).to eq({})
    end
  end
end