# Written for de-duplication of notes created from Twitter favorites

require 'Evernote_connection'

notes = get_all_notes_from_default_notebook

have_seen_note_title = {}

notes.each { |note|
  if have_seen_note_title[note.title] then
    # puts note.title
    @noteStore.expungeNote( @authToken, note.guid )
  else
    have_seen_note_title[note.title] = TRUE
  end
}