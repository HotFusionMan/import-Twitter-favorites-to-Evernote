# Written for de-duplication of notes created from Twitter favorites

require 'Evernote_connection'
require 'rexml/document'
require 'post_Evernote_note'
require 'linkify'


notes = get_all_notes_from_default_notebook

notes.each_with_index { |note, i|
  # note.struct_fields.each_value { |value|
  #   name = value[:name]
  #   puts "#{name}=#{note.send( name )}"
  # }

  xml_document = REXML::Document.new( @noteStore.getNoteContent( @authToken, note.guid ) )
  content_node = xml_document.root.get_elements( '//en-note' ).first
  content = content_node.text

  updated_note = Evernote::EDAM::Type::Note.new
  updated_note.guid = note.guid
  updated_note.title = note.title
  updated_note.content = build_Evernote_note_content( linkify( content ) )
  updated_note.created = note.created
  updated_note.updated = Time.now.to_i * 1000

  begin
    updated_note_metadata = @noteStore.updateNote( @authToken, updated_note )
    puts "Note was updated, GUID = #{updated_note_metadata.guid}"
  rescue Thrift::Exception => e
    puts "Error occurred on note with GUID #{note.guid} : #{e.errorCode}"
  end
}