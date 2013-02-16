# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # The exceptions which are triggered by the parser.
  module Exceptions
    # Error raised when a date is invalid.
    class InvalidDate < ::Exception
    end

    # Error raised when there is a parsing error.
    class Parsing < ::Exception
    end

    # Error raised when a requested object is not available in any of the desired locales.
    class UnavailableLocale < ::Exception
    end

    # Error raised when there a invalid parsing or rendering engine is requested.
    class UnknownEngine < ::Exception
    end

    # Error raised when a requested method must be overridden by a subclass.
    class Unimplemented < ::Exception
    end
  end
end