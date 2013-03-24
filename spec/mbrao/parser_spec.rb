# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::Parser do
  class BlankParser
    def parse(content, options)

    end
  end

  class ::Mbrao::ParsingEngines::ScopedParser
    def parse(content, options)

    end
  end

  shared_examples_for("attribute_with_default") do |attribute, default, sanitizer|
    it "should return the default value" do
      ::Mbrao::Parser.send("#{attribute}=", nil)
      expect(::Mbrao::Parser.send(attribute)).to eq(default)
    end

    it "should return the set value sanitized" do
      ::Mbrao::Parser.send("#{attribute}=", :en)
      expect(::Mbrao::Parser.send(attribute)).to eq("en".send(sanitizer))
    end
  end

  describe ".locale" do
    it_should_behave_like("attribute_with_default", :locale, "en", :ensure_string)
  end

  describe ".parsing_engine" do
    it_should_behave_like("attribute_with_default", :parsing_engine, :plain_text, :to_sym)
  end

  describe ".rendering_engine" do
    it_should_behave_like("attribute_with_default", :rendering_engine, :html_pipeline, :to_sym)
  end

  describe ".parse" do
    it "should forward to the instance" do
      ::Mbrao::Parser.instance.should_receive(:parse).with("TEXT", {options: {}})
      ::Mbrao::Parser.parse("TEXT", {options: {}})
    end
  end

  describe ".render" do
    it "should forward to the instance" do
      ::Mbrao::Parser.instance.should_receive(:render).with("TEXT", {options: {}}, {content: {}})
      ::Mbrao::Parser.render("TEXT", {options: {}}, {content: {}})
    end
  end

  describe ".create_engine" do
    it "should create an engine via Lazier.find_class" do
      reference = ::Mbrao::ParsingEngines::ScopedParser.new
      cls = ::Mbrao::ParsingEngines::ScopedParser
      cls.should_receive(:new).exactly(2).and_return(reference)

      ::Lazier.should_receive(:find_class).with(:scoped_parser, "::Mbrao::ParsingEngines::%CLASS%").and_return(cls)
      expect(::Mbrao::Parser.create_engine(:scoped_parser)).to eq(reference)
      ::Lazier.should_receive(:find_class).with(:scoped_parser, "::Mbrao::RenderingEngines::%CLASS%").and_return(cls)
      expect(::Mbrao::Parser.create_engine(:scoped_parser, :rendering)).to eq(reference)
    end

    it "should raise an exception if the engine class is not found" do
      expect { ::Mbrao::Parser.create_engine(:invalid) }.to raise_error(::Mbrao::Exceptions::UnknownEngine)
    end
  end

  describe ".instance" do
    it("should call .new") do
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
      ::Mbrao::Parser.should_receive(:new)
      ::Mbrao::Parser.instance
    end

    it("should return the same instance") do
      ::Mbrao::Parser.stub(:new) do Time.now end
      instance = ::Mbrao::Parser.instance
      expect(::Mbrao::Parser.instance).to be(instance)
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
    end

    it("should return a new instance if requested to") do
      ::Mbrao::Parser.stub(:new) do Time.now end
      instance = ::Mbrao::Parser.instance
      expect(::Mbrao::Parser.instance(true)).not_to be(instance)
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
    end
  end

  describe ".is_email?" do
    it "should check for valid emails" do
      expect(Mbrao::Parser.is_email?("valid@email.com")).to be_true
      expect(Mbrao::Parser.is_email?("valid@localhost")).to be_false
      expect(Mbrao::Parser.is_email?("this.is.9@email.com")).to be_true
      expect(Mbrao::Parser.is_email?("INVALID")).to be_false
      expect(Mbrao::Parser.is_email?(nil)).to be_false
      expect(Mbrao::Parser.is_email?([])).to be_false
      expect(Mbrao::Parser.is_email?("this.is.9@email.com.uk")).to be_true
    end
  end

  describe ".is_url?" do
    it "should check for valid URLs" do
      expect(Mbrao::Parser.is_url?("http://google.it")).to be_true
      expect(Mbrao::Parser.is_url?("ftp://ftp.google.com")).to be_true
      expect(Mbrao::Parser.is_url?("http://google.it/?q=FOO+BAR")).to be_true
      expect(Mbrao::Parser.is_url?("INVALID")).to be_false
      expect(Mbrao::Parser.is_url?([])).to be_false
      expect(Mbrao::Parser.is_url?(nil)).to be_false
      expect(Mbrao::Parser.is_url?({})).to be_false
    end
  end

  describe ".sanitized_hash" do
    it "should inject a new hash from existing one" do
      reference = {a: "b"}
      reference.should_receive(:inject).with(an_instance_of(HashWithIndifferentAccess)).and_call_original
      sanitized = Mbrao::Parser.sanitized_hash(reference)
      expect(sanitized).to be_a(HashWithIndifferentAccess)
      expect(sanitized["a"]).to eq("b")

    end

    it "should collect sanitized elements" do
      reference = [{a: "b"}]
      reference.should_receive(:collect).and_call_original
      sanitized = Mbrao::Parser.sanitized_hash(reference)
      expect(sanitized).to be_a(Array)
      expect(sanitized[0]).to eq({"a" => "b"})

    end

    it "should iterate over nested elements recursively" do
      reference = [{a: "b"}]
      Mbrao::Parser.should_receive(:sanitized_hash).with(anything, :ensure_array).exactly(4).and_call_original
      sanitized = Mbrao::Parser.sanitized_hash({c: reference}, :ensure_array)
      expect(sanitized).to be_a(HashWithIndifferentAccess)
      expect(sanitized["c"]).to eq([{"a" => ["b"]}])
    end

    it "should convert a non-enumerable object using a method" do
      reference = {a: "b"}
      expect(Mbrao::Parser.sanitized_hash(reference, :ensure_array).fetch("a")).to eq(["b"])
    end

    it "should convert a non-enumerable object using a block" do
      reference = {a: ["b", "c"]}
      expect((Mbrao::Parser.sanitized_hash(reference) {|v| v.upcase }.fetch("a"))).to eq(["B", "C"])
    end

    it "should not modify a non-enumerable object if requested to" do
      reference = {a: nil}
      expect((Mbrao::Parser.sanitized_hash(reference, false).fetch("a"))).to be_nil
    end
  end

  describe ".sanitized_array" do
    it "should return a sanitized array" do
      expect(Mbrao::Parser.sanitized_array([:en, ["A", 1]])).to eq(["en", "A", "1"])
      expect(Mbrao::Parser.sanitized_array(:en)).to eq(["en"])
      expect(Mbrao::Parser.sanitized_array(:en)).to eq(["en"])
      expect(Mbrao::Parser.sanitized_array([:en, nil])).to eq(["en", ""])
    end

    it "should not uniq if requested to" do
      ref = [{a: "b"}]
      ref.should_not_receive(:uniq)
      expect(Mbrao::Parser.sanitized_array(ref, false)).to eq(["{:a=>\"b\"}"])
    end

    it "should compact if requested to" do
      ref = [{a: "b"}, nil]
      ref.should_not_receive(:compact)
      expect(Mbrao::Parser.sanitized_array(ref, false, true)).to eq(["{:a=>\"b\"}"])
    end

    it "should use the requested method for sanitizing" do
      ref = [{a: "b"}]
      ref.should_not_receive(:ensure_string)
      Hash.any_instance.should_receive(:to_json).and_call_original
      expect(Mbrao::Parser.sanitized_array(ref, true, false, :to_json)).to eq(["{\"a\":\"b\"}"])
    end

    it "should use the block for sanitizing" do
      ref = [{a: "b"}]
      ref.should_not_receive(:ensure_string)
      expect(Mbrao::Parser.sanitized_array(ref) {|e| e.keys.first }).to eq([:a])
    end
  end

  describe "#parse" do
    it "should sanitize options" do
      reference = BlankParser.new
      ::Mbrao::Parser.should_receive(:create_engine).exactly(3).and_return(reference)

      reference.should_receive(:parse).with("CONTENT", {"metadata" => true, "content" => true, "engine" => :blank_parser})
      reference.should_receive(:parse).with("CONTENT", {"metadata" => true, "content" => false, "engine" => :blank_parser})
      reference.should_receive(:parse).with("CONTENT", {"metadata" => false, "content" => false, "engine" => :blank_parser})

      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, content: 2})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, metadata: false, content: false})
    end

    it "should call .create_engine call its #parse method" do
      reference = BlankParser.new
      ::Mbrao::Parser.should_receive(:create_engine).and_return(reference)

      reference.should_receive(:parse).with("CONTENT", {"metadata" => true, "content" => true, "engine" => :blank_parser, "other" => "OK"})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, other: "OK"})
    end
  end

  describe "#render" do
    it "should sanitize options" do
      reference = Object.new
      ::Mbrao::Parser.should_receive(:create_engine).exactly(2).and_return(reference)

      reference.should_receive(:render).with("CONTENT", {"engine" => :blank_rendered}, {content: "OK"})
      reference.should_receive(:render).with("CONTENT", {"engine" => :html_pipeline}, {content: "OK"})

      ::Mbrao::Parser.new.render("CONTENT", {engine: :blank_rendered}, {content: "OK"})
      ::Mbrao::Parser.new.render("CONTENT", {engine: :html_pipeline}, {content: "OK"})
    end

    it "should call .create_engine call its #parse method" do
      reference = Object.new
      ::Mbrao::Parser.should_receive(:create_engine).with(:blank_rendered, :rendering).and_return(reference)

      reference.should_receive(:render).with("CONTENT", {"engine" => :blank_rendered}, {content: "OK"})
      ::Mbrao::Parser.new.render("CONTENT", {engine: :blank_rendered}, {content: "OK"})
    end
  end
end