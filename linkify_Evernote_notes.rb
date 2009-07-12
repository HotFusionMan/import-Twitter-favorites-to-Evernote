# Written for de-duplication of notes created from Twitter favorites

require 'Evernote_connection'

noteList = get_all_notes_from_default_notebook

notes = noteList.notes

max_index = 1
notes.each_with_index { |note, i|
  note.struct_fields.each_value { |value|
    name = value[:name]
    puts "#{name}=#{note.send( name )}"
  }
  puts
  break if i >= max_index
}

=begin
==
===
=~
__id__
__send__
active
active=
attributes
attributes=
class
clone
content
content=
contentHash
contentHash=
contentLength
contentLength=
created
created=
deleted
deleted=
differences
display
dup
each_field
eql?
equal?
extend
fields_with_default_values
freeze
frozen?
guid
guid=
hash
id
inspect
instance_eval
instance_of?
instance_variable_defined?
instance_variable_get
instance_variable_set
instance_variables
is_a?
kind_of?
method
methods
name_to_id
nil?
notebookGuid
notebookGuid=
object_id
private_methods
protected_methods
public_methods
read
resources
resources=
respond_to?
send
singleton_methods
struct_fields
tagGuids
tagGuids=
taguri
taguri=
taint
tainted?
title
title=
to_a
to_s
to_yaml
to_yaml_properties
to_yaml_style
type
untaint
updateSequenceNum
updateSequenceNum=
updated
updated=
validate
write
=end