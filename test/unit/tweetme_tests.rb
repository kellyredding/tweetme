require 'assert'
require 'tweetme'

module Tweetme

  class UnitTests < Assert::Context
    desc "Tweetme"
    subject{ Tweetme }

    should have_imeths :run

  end

end
