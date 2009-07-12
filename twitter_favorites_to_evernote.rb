=begin
sudo gem install oauth --version 0.3.4
# As of this writing, the following installs twitter 0.6.11, which requires exactly the versions of the other gems mentioned in this comment.  oauth is a prerequisite to installing twitter, the others are needed by twitter at runtime.
sudo gem install jnunemaker-twitter --source http://gems.github.com
sudo gem install mash --version 0.0.3
sudo gem install httparty --version 0.4.3
=end

require 'config_store'
require 'twitter'
require 'post_Evernote_note'
require 'rexml/document'
require 'linkify'


twitter_config = ConfigStore.new( "#{ENV['HOME']}/.twitter" )

twitter_username = twitter_config['username']
twitter_password = twitter_config['password']


httpauth = Twitter::HTTPAuth.new( twitter_username, twitter_password, :ssl => TRUE )
base = Twitter::Base.new( httpauth )

#page_number = 1
loop do
  begin
    begin
      page = base.favorites #( :page => page_number ) # Given that we're going to un-favorite tweets as we go, it only makes sense to always retrieve the newest page of favorites, which will be progressively older tweets as we go along.
    rescue Twitter::NotFound => e
      puts "#{e.message} on tweet #{tweet.id}; sleeping for 5 seconds before retrying"
      sleep 5
      retry
    end

    unless page.empty?
      page.each { |tweet|
        begin
          post_to_Evernote tweet.id.to_s, linkify( REXML::Text.new( tweet.text ).to_s )
        rescue => e
          puts "Had a problem posting tweet #{tweet.id} to Evernote: #{e.message}"
          $! = TRUE
        end

        if $!.nil? then
          begin
            base.favorite_destroy tweet.id
          rescue Twitter::NotFound => e
            puts "#{e.message} on tweet #{tweet.id}; sleeping for 5 seconds before retrying"
            sleep 5
            retry
          end
        else
          $! = nil
        end
      }

      #page_number += 1
    else
      break
    end
  rescue Twitter::RateLimitExceeded => e
    minutes_until_rate_limit_is_reset = ( base.rate_limit_status.reset_time_in_seconds - Time.now.to_i ) / 60.0
    puts "Sorry, we've exceeded the Twitter-imposed rate limit for accessing their service.  We'll have to wait #{minutes_until_rate_limit_is_reset} minutes before this account can access Twitter again."
    exit
  end
end
