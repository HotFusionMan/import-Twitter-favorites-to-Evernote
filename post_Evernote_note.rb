require 'Evernote_connection'

def build_Evernote_note_content( content )
  '<?xml version="1.0" encoding="UTF-8"?>' +
    '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml.dtd">' +
    '<en-note>' +
     content +
    '</en-note>'
end

def post_to_Evernote( note_title, well_formed_XHTML_note_content )
  #puts "Creating a new note in the default notebook: #{defaultNotebook.name}"
  #puts
  note = Evernote::EDAM::Type::Note.new
  note.notebookGuid = @defaultNotebook.guid

  note.title = note_title.strip
  note.content = build_Evernote_note_content( well_formed_XHTML_note_content.strip )
  note.created = Time.now.to_i * 1000
  note.updated = note.created

  begin
    createdNote = @noteStore.createNote( @authToken, note )
    puts "Note was created, GUID = #{createdNote.guid}"
  rescue Thrift::Exception => e
    puts "Error occurred on note with title #{note.title} : #{e.errorCode}"
  end
end


if $0 == __FILE__ then
  note_title = Readline.readline( 'title:  ' )
  content = Readline.readline( 'content:  ' )
  post_to_Evernote note_title, content
end
