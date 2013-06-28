#+--------------------------------------------------------------------+
#  tag_model.coffee
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
class Tag_model extends Model
  
  Tag_model :  ->
    parent::Model()
    
  
  get_all_tags : ($allow_none = true) ->
    $options = {}
    if $allow_none then $options[0] = "(None)"@db.from('tags').order_by('title', 'asc')
    $tag_q = @db.get()
    for $row in $tag_q.result()
      $options[$row.id] = $row.title
      
    return $options
    
  
  show_entry_tag : ($tag_id) ->
    if $tag_id < 1 then return ""@db.from('tags').where('id', $tag_id).limit(1)
    $tag_q = @db.get()
    if $tag = $tag_q.row()) then "<span class=\"tags\" style=\"color:#" + $tag.color + "; background-color:#" + $tag.background + "\">" + $tag.title + "</span>"
    else return ""}show_entry_tag_link : ($tag_id) ->
      if $tag_id < 1 then return ""@db.from('tags').where('id', $tag_id).limit(1)
      $tag_q = @db.get()
      if $tag = $tag_q.row()) then "<span class=\"tags\" style=\"color:#" + $tag.color + "; background-color:#" + $tag.background + "\">" + anchor("entry/show/tag/" + $tag.id, $tag.title, 'style':'text-decoration:none;color:#' + $tag.color + ';') + "</span>"
      else return ""}tag_name : ($tag_id) ->
        if $tag_id < 1 then return ""@db.from('tags').where('id', $tag_id).limit(1)
        $tag_q = @db.get()
        if $tag = $tag_q.row()) then $tag.title
        else return ""}}
module.exports = Tag_model