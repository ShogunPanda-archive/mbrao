# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # The exceptions raised by mbrao.
  module Exceptions
    # Exception raised when metadata are not valid.
    class InvalidMetadata < RuntimeError
    end

    # Exception raised when a date is valid.
    class InvalidDate < RuntimeError
    end

    # Exception raised when there is a parsing error.
    class Parsing < RuntimeError
    end

    # Exception raised when there is a rendering error.
    class Rendering < RuntimeError
    end

    # Exception raised when a requested object is not available in any of the desired locales.
    class UnavailableLocalization < RuntimeError
    end

    # Exception raised when a invalid parsing or rendering engine is requested.
    class UnknownEngine < RuntimeError
    end

    # Exception raised when a requested method must be overridden by a subclass.
    class Unimplemented < RuntimeError
    end
  end
end
