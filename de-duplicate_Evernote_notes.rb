# Written for de-duplication of notes created from Twitter favorites

require 'Evernote_connection'

filter = Evernote::EDAM::NoteStore::NoteFilter.new
filter.notebookGuid = @defaultNotebook.guid
filter.order = Evernote::EDAM::Type::NoteSortOrder::CREATED
filter.ascending = TRUE

begin
  noteList = @noteStore.findNotes( @authToken, filter, 0, 10000 ) # Evernote doesn't like using big numbers here such as MAX_INT32 )
rescue => e
  puts e #.message
  exit
end

have_seen_note_title = {}

notes = noteList.notes

notes.each { |note|
  if have_seen_note_title[note.title] then
    # puts note.title
    @noteStore.expungeNote( @authToken, note.guid )
  else
    have_seen_note_title[note.title] = TRUE
  end
}