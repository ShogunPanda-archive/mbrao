# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
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
    def initialize(name, email = nil, website = nil, image = nil, metadata = nil)
      @name = name.ensure_string
      @email = Mbrao::Parser.email?(email) ? email : nil
      @website = Mbrao::Parser.url?(website) ? website : nil
      @image = Mbrao::Parser.url?(image) ? image : nil
      @metadata = metadata.ensure_hash(:indifferent)
    end

    # Returns the author as an Hash.
    #
    # @param options [Hash] Options to modify behavior of the serialization.
    #   The only supported value are:
    #
    #   * `:exclude`, an array of attributes to skip.
    #   * `:exclude_empty`, if to exclude nil values. Default is `false`.
    # @return [Hash] An hash with all attributes.
    def as_json(options = {})
      keys = [:uid, :name, :email, :website, :image, :metadata]
      ::Mbrao::Parser.as_json(self, keys, options)
    end

    # Creates an author from a `Hash`.
    #
    # @param data [Hash] The data of the author
    # @return [Author] A new author.
    def self.create(data)
      if data.is_a?(Hash)
        data = HashWithIndifferentAccess.new(data)
        uid = data.delete(:uid)
        metadata = data.delete(:metadata) || {}
        author = Mbrao::Author.new(data.delete(:name), data.delete(:email), data.delete(:website), data.delete(:image), metadata.merge(data))
        author.uid = uid
        author
      else
        Mbrao::Author.new(data)
      end
    end
  end
end
