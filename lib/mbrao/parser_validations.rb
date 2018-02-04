# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

# A content parser and renderer with embedded metadata support.
module Mbrao
  # Methods to perform validations.
  module ParserValidations
    extend ActiveSupport::Concern

    # Class methods.
    module ClassMethods
      # Checks if the text is a valid email.
      #
      # @param text [String] The text to check.
      # @return [Boolean] `true` if the string is valid email, `false` otherwise.
      def email?(text)
        /^([a-z0-9_\.\-\+]+)@([\da-z\.\-]+)\.([a-z\.]{2,6})$/i.match(text.ensure_string.strip)
      end

      # Checks if the text is a valid URL.
      #
      # @param text [String] The text to check.
      # @return [Boolean] `true` if the string is valid URL, `false` otherwise.
      def url?(text)
        %r{
          ^(
            ([a-z0-9\-]+:\/\/) #PROTOCOL
            (([\w-]+\.)?) # LOWEST TLD
            ([\w-]+) # 2nd LEVEL TLD
            (\.[a-z]+) # TOP TLD
            ((:\d+)?) # PORT
            ([\S|\?]*) # PATH, QUERYSTRING AND FRAGMENT
          )$
        }ix.match(text.ensure_string.strip)
      end
    end
  end
end
