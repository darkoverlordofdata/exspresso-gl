#+--------------------------------------------------------------------+
#  group_model.coffee
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
class Group_model extends Model
  
  Group_model :  ->
    parent::Model()
    
  
  get_all_groups : ($id = null) ->
    $options = {}
    if $id is null then @db.from('groups').where('id >', 0).order_by('name', 'asc')
    else @db.from('groups').where('id >', 0).where('id !=', $id).order_by('name', 'asc')
    $group_parent_q = @db.get()
    for $row in $group_parent_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
  get_ledger_groups :  ->
    $options = {}
    @db.from('groups').where('id >', 4).order_by('name', 'asc')
    $group_parent_q = @db.get()
    for $row in $group_parent_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
module.exports = Group_model
