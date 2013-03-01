# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
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
  #   @return [HashWithIndifferentAccess] The full list of metadata of this author.
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
    # @param metadata [HashWithIndifferentAccess] The full list of metadata of this author.
    # @param uid [String] A unique ID for this post. This is only for client uses.
    def initialize(name, email = nil, website = nil, image = nil, metadata = nil, uid = nil)
      @name = name.ensure_string
      @email = Mbrao::Parser.is_email?(email) ? email : nil
      @website = Mbrao::Parser.is_url?(website) ? website : nil
      @image = Mbrao::Parser.is_url?(image) ? image : nil
      @metadata = Mbrao::Parser.sanitized_hash(metadata)
      @uid = uid
    end

    # Creates an author from a `Hash`.
    #
    # @param data [Hash] The data of the author
    # @return [Author] A new author.
    def self.create(data)
      if data.is_a?(Hash) then
        data = HashWithIndifferentAccess.new(data)
        uid = data.delete(:uid)
        Mbrao::Author.new(data.delete(:name), data.delete(:email), data.delete(:website), data.delete(:image), data, uid)
      else
        Mbrao::Author.new(data)
      end
    end
  end
end