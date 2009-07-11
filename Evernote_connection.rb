require "readline"
require 'thrift'
require "Evernote/EDAM/user_store"
require "Evernote/EDAM/user_store_constants"
require "Evernote/EDAM/note_store"
require "Evernote/EDAM/Limits_constants"

require 'config_store'

#
# Configure these based on the API key you received from Evernote
#


evernote_config = ConfigStore.new( "#{ENV['HOME']}/.evernote" )

evernote_username = evernote_config['username']
evernote_password = evernote_config['password']
evernote_consumer_key = evernote_config['consumer_key']
evernote_consumer_secret = evernote_config['consumer_secret']


# edamBaseUrl = 'http://sandbox.evernote.com'
edamBaseUrl = 'https://www.evernote.com'

userStoreUrl = edamBaseUrl + "/edam/user"
userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)

versionOK = userStore.checkVersion("Ruby EDAMTest",
                                Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
                                Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
puts "Is my EDAM protocol version up to date?  #{versionOK}"
if (!versionOK)
  exit(1)
end

authResult = userStore.authenticate(evernote_username, evernote_password, evernote_consumer_key, evernote_consumer_secret)
user = authResult.user
@authToken = authResult.authenticationToken
#puts "Authentication was successful for #{user.evernote_username}"
#puts "Authentication token = #{authToken}"

noteStoreUrl = edamBaseUrl + "/edam/note/" + user.shardId
noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
@noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

notebooks = @noteStore.listNotebooks( @authToken )
#puts "Found #{notebooks.size} notebooks:"
@defaultNotebook = notebooks[0]
notebooks.each { |notebook|
#  puts "  * #{notebook.name}"
  if (notebook.defaultNotebook)
    @defaultNotebook = notebook
  end
}

MAX_INT32 = 2**31 - 1