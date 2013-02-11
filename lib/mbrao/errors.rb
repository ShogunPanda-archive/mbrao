# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # The errors which are triggered by the parser.
  module Errors
    # Error raised when there is a parsing error.
    class Parsing < ::Exception
    end

    # Error raised when there a invalid rendered was requested.
    class UnknownRenderer < ::Exception
    end
  end
end