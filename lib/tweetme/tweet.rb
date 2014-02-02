module Tweetme

  class Tweet

    attr_reader :status_id, :created_at, :user, :body, :url

    def initialize(data = nil)
      (data || {}).tap do |d|
        @status_id  = d['status_id']
        @created_at = d['created_at']
        @user       = d['user']
        @body       = d['body']
        @url        = d['url']
      end
    end

  end

end
