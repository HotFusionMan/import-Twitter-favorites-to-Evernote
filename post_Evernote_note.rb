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

def post_to_Evernote( note_title, well_formed_XHTML_note_content )
  #puts "Creating a new note in the default notebook: #{defaultNotebook.name}"
  #puts
  note = Evernote::EDAM::Type::Note.new
  note.notebookGuid = @defaultNotebook.guid

  note.title = note_title.strip
  note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml.dtd">' +
    '<en-note>' +
    well_formed_XHTML_note_content.strip +
    '</en-note>'
  note.created = Time.now.to_i * 1000
  note.updated = note.created

  begin
    createdNote = @noteStore.createNote( @authToken, note )
    puts "Note was created, GUID = #{createdNote.guid}"
  rescue Thrift::Exception => e
    puts e.message
    raise
  end
end


if $0 == __FILE__ then
  note_title = Readline.readline( 'title:  ' )
  content = Readline.readline( 'content:  ' )
  post_to_Evernote note_title, content
end
