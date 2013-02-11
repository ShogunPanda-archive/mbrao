# encoding: utf-8
#
# This file is part of the mbriao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbriao
  # Represents the author of a parsed content, with its metadata.
  #
  # @attribute uid
  #   @return [String] A unique ID for this post. This is only for client uses.
  # @attribute name
  #   @return [String] The name of the author.
  # @attribute email
  #   @return [String] The email of the author.
  # @attribute website
  #   @return [String] The website of the author.
  # @attribute image
  #   @return [String] The URL of the avatar of the author.
  # @attribute metadata
  #   @return [HashWithIndifferentAccesss] The full list of metadata of this author.
  class Author
    attr_accessor :uid
    attr_accessor :name
    attr_accessor :email
    attr_accessor :website
    attr_accessor :image
    attr_accessor :metadata

    # Creates a new author.
    #
    # @param name [String] The name of the author.
    # @param email [String] The email of the author.
    # @param website [String] The website of the author.
    # @param image [String] The URL of the avatar of the author.
    # @param metadata [HashWithIndifferentAccesss] The full list of metadata of this author.
    # @param uid [String] A unique ID for this post. This is only for client uses.
    def initialize(name, email = nil, website = nil, image = nil, metadata = nil, uid = nil)
      @name = name
      @email = email # TODO: Check that is a E-Mail
      @website = website # TODO: Check that is a URL
      @image = image # TODO: Check that is a URL
      @metata = metadata # TODO: Make sure this is a recursive HashWithIndifferentAccesss
      @uid = uid
    end
  end
end