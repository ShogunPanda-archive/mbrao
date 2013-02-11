# encoding: utf-8
#
# This file is part of the mbriao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A pipelined content parser with metadata support.
module Mbriao
  # Methods to allow class level access.
  module ParserClassAccess
    def self.register_renderer(name, &block)
      self.instance.register_renderer(name, &block)
    end

    def self.parse(content, options = {})
      self.instance.parser(content, options)
    end

    def self.render(content, renderer, options = {}, context = {})
      self.instance.render(content, renderer, options = {}, context = {})
    end

    # Returns a unique (singleton) instance of the parser.
    #
    # @param force [Boolean] If to force recreation of the instance.
    # @return [Parser] The unique (singleton) instance of the parser.
    def self.instance(force = false)
      @instance = nil if force
      @instance ||= Mbriao::Parser.new
    end
  end

  # A parser to handle pipelined content.
  #
  class Parser
    include Mbriao::ParserClassAccess

    def parse(content, options = {})
      # TODO
    end

    def render(content, renderer, options = {}, context = {})
      # TODO
    end

    def register_renderer(name, &block)
      # TODO
    end
  end
end