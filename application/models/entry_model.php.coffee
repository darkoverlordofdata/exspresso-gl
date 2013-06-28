#+--------------------------------------------------------------------+
#  entry_model.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#
# This file was ported from php to coffee-script using php2coffee
#
#

<% 
class Entry_model extends Model
  
  Entry_model :  ->
    parent::Model()
    
  
  next_entry_number : ($entry_type_id) ->
    @db.select_max('number', 'lastno').from('entries').where('entry_type', $entry_type_id)
    $last_no_q = @db.get()
    if $row = $last_no_q.row()) then $last_no = $row.lastno$last_no++
    return $last_no
    }else 
      return 1
      
    
  
  get_entry : ($entry_id, $entry_type_id) ->
    @db.from('entries').where('id', $entry_id).where('entry_type', $entry_type_id).limit(1)
    $entry_q = @db.get()
    return $entry_q.row()
    
  
module.exports = Entry_model
