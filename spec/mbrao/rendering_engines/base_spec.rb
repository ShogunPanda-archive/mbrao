# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Mbrao::RenderingEngines::Base do
  subject{ Mbrao::RenderingEngines::Base.new }

  describe "#render" do
    it "should raise an exception" do
      expect { subject.render("CONTENT", {}, {}) }.to raise_error(Mbrao::Exceptions::Unimplemented)
    end
  end
end