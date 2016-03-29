# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::Content do
  subject { Mbrao::Content.new("UID") }

  describe "#initialize" do
    it "store the uid" do
      subject = Mbrao::Content.new("SAMPLE")
      expect(subject.uid).to eq("SAMPLE")
    end
  end

  describe "#locales=" do
    it "correctly assign a string, a symbol or an array" do
      subject.locales = :it
      expect(subject.locales).to eq(["it"])
      subject.locales = "en"
      expect(subject.locales).to eq(["en"])
      subject.locales = ["en", [:it, :es]]
      expect(subject.locales).to eq(["en", "it", "es"])
    end
  end

  shared_examples_for("localized setter") do |attribute|
    it "should assign a single string" do
      subject.send("#{attribute}=", "ABC")
      expect(subject.send(attribute)).to eq("ABC")
      subject.send("#{attribute}=", 1)
      expect(subject.send(attribute)).to eq("1")
      subject.send("#{attribute}=", nil)
      expect(subject.send(attribute)).to eq("")
    end

    it "should assign a string with locales and sanitized entries" do
      subject.send("#{attribute}=", {en: nil, es: "ABC", it: 1})
      value = subject.send(attribute)
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value["en"]).to eq("")
      expect(value[:es]).to eq("ABC")
      expect(value["it"]).to eq("1")
    end
  end

  shared_examples_for("localized getter") do |attribute, v1, v2|
    it "should raise an exception if not available for that locale" do
      subject.locales = [:en, :it, :es]
      subject.send("#{attribute}=", v1)
      expect { subject.send("get_#{attribute}", [:de, :it]) }.not_to raise_error
      expect { subject.send("get_#{attribute}", [:de]) }.to raise_error(Mbrao::Exceptions::UnavailableLocalization)
    end

    it "should return the attribute itself if not localized" do
      subject.locales = [:en, :it, :es]
      subject.send("#{attribute}=", v1)
      expect(subject.send("get_#{attribute}", [:de, :it])).to eq(v1)
    end

    it "should return the default locale if no locales are specified" do
      Mbrao::Parser.locale = :it
      subject.send("#{attribute}=", {en: v1, it: v2})
      expect(subject.send("get_#{attribute}")).to eq(v2)
    end

    it "should return only the subset of valid and request locales" do
      Mbrao::Parser.locale = :it
      subject.send("#{attribute}=", {en: v1, it: v2, de: v1, es: v2})

      value = subject.send("get_#{attribute}", [:de, :es])
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value.keys).to eq(["de", "es"])

      value = subject.send("get_#{attribute}", [:it, :de, :pt, :fr])
      expect(value.keys.sort).to eq(["de", "it"])

      subject.locales = [:en, :it, :es]
      value = subject.send("get_#{attribute}", "*")
      expect(value.keys.sort).to eq(["de", "en", "es", "it"])

      subject.send("#{attribute}=", {en: v1, "it,es" => v2, " de,    fr " => v1})
      value = subject.send("get_#{attribute}", [:it, :fr])
      expect(value.keys.sort).to eq(["fr", "it"])
    end
  end

  shared_examples_for("date setter") do |attribute|
    it "should correctly parse a datetime classes" do
      subject.send("#{attribute}=", Date.civil(2012, 8, 8))
      value = subject.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T000000+0000")

      subject.send("#{attribute}=", DateTime.civil(2012, 8, 8, 11, 30, 45))
      value = subject.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T113045+0000")

      Time.zone = 'Europe/Rome'
      date = Time.at(1344421800)
      subject.send("#{attribute}=", date)
      value = subject.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103000+0000")
    end

    it "should correctly parse a timestamp" do
      subject.send("#{attribute}=", 1344421800)
      value = subject.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103000+0000")
    end

    it "should try to parse everything else as a ISO8601 format" do
      # "%Y%m%dT%H%M%S%z", "%Y%m%dT%H%M%S%Z"
      subject.send("#{attribute}=", "20120808T083045-0200")
      value = subject.send(attribute)
      expect(value).to be_a(DateTime)
      expect(value.strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      subject.send("#{attribute}=", "20120808T083045-02:00")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      # "%FT%T.%L%z", "%FT%T.%L%Z"
      subject.send("#{attribute}=", "2012-08-08T08:30:45.123-0200")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120808T103045123+0000")

      subject.send("#{attribute}=", "2012-08-08T08:30:45.123-02:00")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120808T103045123+0000")

      # "%FT%T%z", "%FT%T%Z"
      subject.send("#{attribute}=", "2012-08-08T08:30:45-0200")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      subject.send("#{attribute}=", "2012-08-08T08:30:45-02:00")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      # "%F %T %z", "%F %T %Z"
      subject.send("#{attribute}=", "2012-08-08 08:30:45 -0200")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      subject.send("#{attribute}=", "2012-08-08 08:30:45 -02:00")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T103045+0000")

      # "%F %T.%L %z", "%F %T.%L %Z"
      subject.send("#{attribute}=", "2012-08-08 08:30:45.123 -0200")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120808T103045123+0000")

      subject.send("#{attribute}=", "2012-08-08 08:30:45.123 -02:00")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120808T103045123+0000")

      # "%F %T%.L", "%F %T", "%F %H:%M", "%F"
      subject.send("#{attribute}=", "2012-08-08 08:30:45.123")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120808T083045123+0000")

      subject.send("#{attribute}=", "2012-08-08 08:30:45")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T083045+0000")

      subject.send("#{attribute}=", "2012-08-08 08:30")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T083000+0000")

      subject.send("#{attribute}=", "2012-08-08")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120808T000000+0000")

      # "%d/%m/%Y %T.%L", "%d/%m/%Y %T", "%d/%m/%Y %H:%M", "%d/%m/%Y"
      subject.send("#{attribute}=", "08/09/2012 08:30:45.123")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%L%z")).to eq("20120908T083045123+0000")

      subject.send("#{attribute}=", "08/09/2012 08:30:45")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120908T083045+0000")

      subject.send("#{attribute}=", "08/09/2012 08:30")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120908T083000+0000")

      subject.send("#{attribute}=", "08/09/2012")
      expect(subject.send(attribute).strftime("%Y%m%dT%H%M%S%z")).to eq("20120908T000000+0000")

      expect { subject.send("#{attribute}=", "ABC") }.to raise_error(Mbrao::Exceptions::InvalidDate)
      expect { subject.send("#{attribute}=", []) }.to raise_error(Mbrao::Exceptions::InvalidDate)
    end
  end

  describe "#title=" do
    it_should_behave_like "localized setter", :title
  end

  describe "#summary=" do
    it_should_behave_like "localized setter", :summary
  end

  describe "#body=" do
    it "should set the content as string" do
      subject.body = "A"
      expect(subject.body).to eq("A")
      subject.body = 1
      expect(subject.body).to eq("1")
      subject.body = nil
      expect(subject.body).to eq("")
    end
  end

  describe "#tags=" do
    it "should assign a single value" do
      subject.tags = "ABC"
      expect(subject.tags).to eq(["ABC"])
      subject.tags = ["ABC", [1, nil]]
      expect(subject.tags).to eq(["ABC", "1"])
    end

    it "should assign values with locales and sanitized entries" do
      subject.tags = {en: nil, es: "ABC", it: [1, [2, 3]]}
      value = subject.tags
      expect(value).to be_a(::HashWithIndifferentAccess)
      expect(value["en"]).to eq([])
      expect(value[:es]).to eq(["ABC"])
      expect(value["it"]).to eq(["1", "2", "3"])
    end

    it "should split, flatten and uniquize tags" do
      subject.tags = ["1", ["2", "3"], "3, 4,5"]
      expect(subject.tags).to eq(["1","2","3","4","5"])
      subject.tags = "1,2,3,4,5"
      expect(subject.tags).to eq(["1","2","3","4","5"])
    end
  end

  describe "#more=" do
    it_should_behave_like "localized setter", :more
  end

  describe "#author=" do
    it "should assign an existing author" do
      author = ::Mbrao::Author.new("NAME")
      subject.author = author
      expect(subject.author).to be(author)
    end

    it "should only assign a name" do
      subject.author = "NAME"
      expect(subject.author).to be_a(::Mbrao::Author)
      expect(subject.author.name).to eq("NAME")
    end

    it "should assign by an hash" do
      subject.author = {name: "NAME", email: "EMAIL@email.com", "website" => "http://WEBSITE.TLD", "image" => "http://IMAGE.TLD", metadata: {a: "b"}, uid: "UID"}
      expect(subject.author).to be_a(::Mbrao::Author)
      expect(subject.author.name).to eq("NAME")
      expect(subject.author.email).to eq("EMAIL@email.com")
      expect(subject.author.website).to eq("http://WEBSITE.TLD")
      expect(subject.author.image).to eq("http://IMAGE.TLD")
      expect(subject.author.metadata).to be_a(::HashWithIndifferentAccess)
      expect(subject.author.metadata["a"]).to eq("b")
      expect(subject.author.uid).to eq("UID")
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
      subject.metadata = "RAW"
      expect(subject.metadata).to be_a(::HashWithIndifferentAccess)
      expect(subject.metadata["raw"]).to eq("RAW")
    end

    it "correctly set a hash value" do
      subject.metadata = {en: nil, es: "ABC", it: [1, [2, 3]]}
      expect(subject.metadata).to be_a(::HashWithIndifferentAccess)
      expect(subject.metadata["es"]).to eq("ABC")
    end
  end

  describe "#enabled_for_locales?" do
    it "correctly check availability for certain locales" do
      subject.locales = [:en, :it]
      expect(subject.enabled_for_locales?).to be_truthy
      expect(subject.enabled_for_locales?(:en)).to be_truthy
      expect(subject.enabled_for_locales?(:it, :es)).to be_truthy
      expect(subject.enabled_for_locales?(:es, :de)).to be_falsey
    end
  end

  describe "#get_title" do
    it_should_behave_like "localized getter", :title, "ABC", "123"
  end

  describe "#get_body" do
    it "should create a parsing engine and use it for filtering" do
      subject.body = "BODY"
      engine = ::Mbrao::ParsingEngines::Base.new
      expect(engine).to receive(:filter_content).with(subject, ["it", "en"])
      expect(::Mbrao::Parser).to receive(:create_engine).with("ENGINE").and_return(engine)
      subject.get_body(["it", "en"], "ENGINE")
    end
  end

  describe "#get_tags" do
    it_should_behave_like "localized getter", :tags, ["ABC", "123"], ["1", "2", "3", "4"]
  end

  describe "#get_more" do
    it_should_behave_like "localized getter", :more, "ABC", "123"
  end

  describe "#as_json" do
    subject {
      @created_at = DateTime.civil(1984, 7, 7, 11, 30, 0)
      @created_at_s = @created_at.as_json
      metadata = {"uid" => "UID", "title" => {it: "IT", en: "EN"}, "summary" => "SUMMARY", "author" => "AUTHOR", "tags" => {it: "IT", en: "EN"}, "more" => "MORE", created_at: @created_at, locales: ["it", ["en"]], other: ["OTHER"]}
      ::Mbrao::Content.create(metadata, "BODY")
    }

    it "should return the content as a JSON hash" do
      expect(subject.as_json).to eq({
        "author" => {"uid" => nil, "name" => "AUTHOR", "email" => nil, "website" => nil, "image" => nil, "metadata" => {}},
        "summary" => "SUMMARY",
        "body" => "BODY",
        "created_at" => @created_at_s,
        "locales" => ["it", "en"],
        "metadata" => {"other" => ["OTHER"]},
        "more" => "MORE",
        "tags" => {"it" => ["IT"], "en"=>["EN"]},
        "title" => {"it" => "IT", "en" => "EN"},
        "uid" => "UID",
        "updated_at" => @created_at_s
      })
    end

    it "should filter out keys if asked to" do
      expect(subject.as_json(exclude: [:author, :uid])).to eq({
        "summary" => "SUMMARY",
        "body" => "BODY",
        "created_at" => @created_at_s,
        "locales" => ["it", "en"],
        "metadata" => {"other" => ["OTHER"]},
        "more" => "MORE",
        "tags" => {"it" => ["IT"], "en"=>["EN"]},
        "title" => {"it" => "IT", "en" => "EN"},
        "updated_at" => @created_at_s
      })
    end

    it "should filter out empty values if asked to" do
      subject.author = nil
      subject.uid = nil

      expect(subject.as_json(exclude_empty: true)).to eq({
        "summary" => "SUMMARY",
        "body" => "BODY",
        "created_at" => @created_at_s,
        "locales" => ["it", "en"],
        "metadata" => {"other" => ["OTHER"]},
        "more" => "MORE",
        "tags" => {"it" => ["IT"], "en"=>["EN"]},
        "title" => {"it" => "IT", "en" => "EN"},
        "updated_at" => @created_at_s
      })
    end
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
      metadata = {"uid" => "UID", "title" => {it: "IT", en: "EN"}, "summary" => {it: "IT", en: "EN"}, "author" => "AUTHOR", "tags" => {it: "IT", en: "EN"}, "more" => "MORE", created_at: created_at, locales: ["it", ["en"]], other: ["OTHER"]}
      content = ::Mbrao::Content.create(metadata, "BODY")

      expect(content.uid).to eq("UID")
      expect(content.title).to eq({"it" => "IT", "en" => "EN"})
      expect(content.summary).to eq({"it" => "IT", "en" => "EN"})
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