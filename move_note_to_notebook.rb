require 'Evernote_connection'

def move_note_to_notebook( note_guid, notebook_guid )
    begin
    note = @noteStore.getNote( @authToken, note_guid, FALSE )
  rescue => e
    puts "Error occurred on note with GUID #{note_guid} : #{e.errorCode}"
  end

  note.notebookGuid = notebook_guid

  begin
    updated_note = @noteStore.updateNote( @authToken, note )
  rescue => e
    puts "Error occurred on note with GUID #{note_guid} : #{e.errorCode}"
  end
end


# file_name = 'problem_GUIDs.txt'
#
# File.open( file_name ) { |file|
#   file.each_line { |line|
#     guid = line.chomp
#
#     move_note_to_notebook( guid, @defaultNotebook.guid )
#   }
# }



source_notebook_guid = nil
@notebooks.each { |notebook|
  if notebook.name == 'Twitter favorites linkified' then
    source_notebook_guid = notebook.guid
  end
}

unless source_notebook_guid.nil?
  defaultNotebook_guid = @defaultNotebook.guid

  notes = get_all_notes_from_notebook( source_notebook_guid )
  notes.each { |note|
    move_note_to_notebook( note.guid, defaultNotebook_guid )
  }
end