# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # The exceptions raised by mbrao.
  module Exceptions
    # Exception raised when metadata are not valid.
    class InvalidMetadata < StandardError
    end

    # Exception raised when a date is valid.
    class InvalidDate < StandardError
    end

    # Exception raised when there is a parsing error.
    class Parsing < StandardError
    end

    # Exception raised when there is a rendering error.
    class Rendering < StandardError
    end

    # Exception raised when a requested object is not available in any of the desired locales.
    class UnavailableLocalization < StandardError
    end

    # Exception raised when a invalid parsing or rendering engine is requested.
    class UnknownEngine < StandardError
    end

    # Exception raised when a requested method must be overridden by a subclass.
    class Unimplemented < StandardError
    end
  end
end