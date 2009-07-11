require 'Evernote_connection'

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
