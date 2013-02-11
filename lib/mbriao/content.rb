# encoding: utf-8
#
# This file is part of the mbriao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbriao
  # Represents a parsed content, with its metadata.
  #
  # @attribute uid
  #   @return [String] A unique ID for this post. This is only for client uses.
  # @attribute locales
  #   @return [Array] A list of locales for this content should be visible. An empty list means that there are no limitations.
  # @attribute title
  #   @return [String|HashWithIndifferentAccess] The content's title. Can be a `String` or an `HashWithIndifferentAccess`, if multiple title are specified for multiple locales.
  # @attribute body
  #   @return [String|HashWithIndifferentAccess] The content's body. Can be a `String` or an `HashWithIndifferentAccess`, if multiple contents are specified for multiple locales.
  # @attribute tags
  #   @return [String|HashWithIndifferentAccess] The content's "more" link label. Can be a `String` or an `HashWithIndifferentAccess`, if multiple labels are specified for multiple locales.
  # @attribute tags
  #   @return [Array|HashWithIndifferentAccess] The tags associated with the content. Can be an `Array` or an `HashWithIndifferentAccess`, if multiple tags set are specified for multiple locales.
  # @attribute author
  #   @return [Author] The post author.
  # @attribute created_at
  #   @return [DateTime] The post creation date and time.
  # @attribute updated_at
  #   @return [DateTime] The post creation date and time. Defaults to the creation date.
  # @attribute metadata
  #   @return [Hash] The full list of metadata of this content.
  class Content
    attr_accessor :uid
    attr_accessor :locales
    attr_accessor :title
    attr_accessor :body
    attr_accessor :tags
    attr_accessor :more
    attr_accessor :author
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :metadata

    def initialize(uid = nil)
      @uid = uid
    end

    # TODO: All setters except uid

    def enabled_for_locales?(locales = [])
      @locales.empty? || (@locales & locales.ensure_array.flatten).present?
    end

    def get_title(locales = [])
      # TODO
    end

    def get_body(locales = [])
      # TODO
    end

    def get_tags(locales = [])
      # TODO
    end

    def get_more(locales = [])
      # TODO
    end
  end
end