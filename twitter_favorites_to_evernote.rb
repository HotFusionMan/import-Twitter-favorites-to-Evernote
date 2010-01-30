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


MAXIMUM_NUMBER_OF_FAVORITES_PER_PAGE = 20


twitter_config = ConfigStore.new( "#{ENV['HOME']}/.twitter" )

twitter_username = twitter_config['username']
twitter_password = twitter_config['password']


httpauth = Twitter::HTTPAuth.new( twitter_username, twitter_password, :ssl => TRUE )
base = Twitter::Base.new( httpauth )

number_of_favorites = base.user( twitter_username )['favourites_count']
number_of_favorites_pages = number_of_favorites / MAXIMUM_NUMBER_OF_FAVORITES_PER_PAGE

number_of_favorites_pages.downto( 1 ) do |page_number|
  puts "page_number: #{page_number}"

  begin
    begin
      page = base.favorites( :page => page_number )
    rescue Twitter::NotFound => e
      puts e.message
      sleep 5
      retry
    rescue => e
      puts e.message
    end

    unless page.empty?
      page.reverse.each { |tweet|
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
          rescue => e
            puts e.message
          end
        else
          $! = nil
        end
      }
    end
  rescue Twitter::RateLimitExceeded => e
    twitter_API_rate_reset_time_in_seconds = base.rate_limit_status.reset_time_in_seconds
    minutes_until_rate_limit_is_reset = ( twitter_API_rate_reset_time_in_seconds - Time.now.to_i ) / 60.0
    puts "Sorry, we've exceeded the Twitter-imposed rate limit for accessing their service.  We'll have to wait #{minutes_until_rate_limit_is_reset} minutes before this account can access Twitter again."
    sleep twitter_API_rate_reset_time_in_seconds
    retry
  rescue Twitter::Unavailable => e
    sleep 5
    retry
  end
end