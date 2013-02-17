# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::ParsingEngines::PlainText do
  let(:reference) { Mbrao::ParsingEngines::PlainText.new }

  let(:sample_metadata) {
    <<EOM
title: "OK"
locales:
  - it
  - en
more:
  it: "Continua"
  en: "Continue"
other:
  status: "OK"
EOM
  }

  let(:sample_content){
    <<EOC
This is a content.

{{content: en}}
Optionally I'm filtered only for English.
{{/content}}
EOC
  }

  let(:sample_valid) {
    <<EOS1


{{metadata}}
#{sample_metadata}
{{/metadata}}

#{sample_content}

EOS1
  }

  let(:sample_invalid) {
    <<EOS2
{{metadata}}
#{sample_content}
EOS2
  }

  let(:sample_no_metadata) {
    <<EOS3
#{sample_content}
EOS3
  }

  let(:sample_nested_content) {
    <<EOS4
START
{{content: it, en}}IT, EN{{/content}}
{{content: *, !en, !it, !es, !fr}}MIDDLE{{/content}}
{{content: !it}}
  {{content: !es}}!IT and !ES{{/content}}
  {{content: en}}EN in !IT{{/content}}

  !IT
{{/content}}
{{content: !*}}END{{/content}}
EOS4
  }

  describe "#separate_components" do
    it "should return correct metadata and contents" do
      expect(reference.separate_components(sample_valid)).to eq([sample_metadata.strip, sample_content.strip])
    end

    it "should return the whole content if metadata are either incorrectly tagged or not present" do
      expect(reference.separate_components(sample_invalid)).to eq(["", sample_invalid.strip])
      expect(reference.separate_components(sample_no_metadata)).to eq(["", sample_no_metadata.strip])
    end

    it "should use different tags" do
      expect(reference.separate_components("[meta]{{metadata}}OK\n[/meta] REST", {meta_tags: ["[meta]", "[/meta]"]})).to eq(["{{metadata}}OK", "REST"])
    end
  end

  describe "#parse_metadata" do
    it "should correctly parse YAML formatted metadata" do
      expect(reference.parse_metadata("---\nyaml:\n  :a: 'b'")).to eq({"yaml" => {a: "b"}})
    end

    it "should return a default value if parsing failed" do
      expect(reference.parse_metadata("---\n\"yaml:", {default: "DEFAULT"})).to eq("DEFAULT")
    end

    it "should raise an exception if parsing failed and no default is available" do
      expect { reference.parse_metadata("---\n\"yaml:") }.to raise_error(::Mbrao::Exceptions::InvalidMetadata)
    end
  end

  describe "#filter_content" do
    def parse_content(content)
      content.split("\n").collect(&:strip).select {|l| l.present? }
    end

    it "should return the original content if locales contains *" do
      expect(parse_content(reference.filter_content(sample_nested_content, "*"))).to eq(["START", "IT, EN", "MIDDLE", "!IT and !ES", "EN in !IT", "!IT", "END"])
    end

    it "should use default locale if nothing is specified" do
      ::Mbrao::Parser.locale = :it
      expect(parse_content(reference.filter_content(sample_nested_content))).to eq(["START", "IT, EN", "MIDDLE", "END"])
    end

    it "should ignore unclosed tag, trying to close the leftmost start tag" do
      expect(parse_content(reference.filter_content("{{content: it}}\n{{content: en}}NO{{/content}}"))).to eq(["{{content: en}}NO"])
    end

    it "should correctly filter by tag" do
      expect(parse_content(reference.filter_content(sample_nested_content, "en"))).to eq(["START", "IT, EN", "MIDDLE", "!IT and !ES", "EN in !IT", "!IT", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, "it"))).to eq(["START", "IT, EN", "MIDDLE", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, "es"))).to eq(["START", "MIDDLE", "!IT", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, "fr"))).to eq(["START", "MIDDLE", "!IT and !ES", "!IT", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, ["it", "en"]))).to eq(["START", "IT, EN", "MIDDLE", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, ["es", "en"]))).to eq(["START", "IT, EN", "MIDDLE", "EN in !IT", "!IT", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, ["fr", "en"]))).to eq(["START", "IT, EN", "MIDDLE", "!IT and !ES", "EN in !IT", "!IT", "END"])
      expect(parse_content(reference.filter_content(sample_nested_content, ["fr", "es", "en"]))).to eq(["START", "IT, EN", "MIDDLE", "EN in !IT", "!IT", "END"])
    end

    it "should use different tags" do
      sample = "[content-it]{{content: !it}}IT[/content]\nOK"
      expect(parse_content(reference.filter_content(sample, "it", {content_tags: ["[content-%ARGS%]", "[/content]"]}))).to eq(["{{content: !it}}IT", "OK"])
      expect(parse_content(reference.filter_content(sample, "en", {content_tags: ["[content-%ARGS%]", "[/content]"]}))).to eq(["OK"])
    end
  end
end