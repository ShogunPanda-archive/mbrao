# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe HTML::Pipeline::KramdownFilter do
  describe "#initialize" do
    it "should call the parent constructor" do
      expect(HTML::Pipeline::TextFilter).to receive(:new).with("\rCONTENT\r", {a: "b"}, {c: "d"})
      HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"})
    end

    it "should remove \r from the text" do
      subject = HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"})
      expect(subject.instance_variable_get(:@text)).to eq("CONTENT")
    end

    it "should use Kramdown with given options for building the result" do
      object = Object.new
      expect(Kramdown::Document).to receive(:new).with("CONTENT", {a: "b"}).and_return(object)
      expect(object).to receive(:to_html)
      HTML::Pipeline::KramdownFilter.new("\rCONTENT\r", {a: "b"}, {c: "d"}).call
    end
  end
end