#+--------------------------------------------------------------------+
#  Messages.coffee
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

<% if not defined('BASEPATH') then die ('No direct script access allowed')

#
# Message:: a class for writing feedback message information to the session
#
# Copyright 2006 Vijay Mahrra & Sheikh Ahmed <webmaster@designbyfail.com>
#
# See the enclosed file COPYING for license information (LGPL).  If you
# did not receive this file, see http://www.fsf.org/copyleft/lgpl.html.
#
# @author  Vijay Mahrra & Sheikh Ahmed <webmaster@designbyfail.com>
# @url http://www.designbyfail.com/
# @version 1.0
#

class Messages

  _ci: {}
  _types: ['success', 'error', 'warning', 'message']
  
  Messages : ($params = {}) ->
    @_ci = get_instance()
    @_ci.load.library('session')
    #  check if theres already messages, if not, initialise the messages array in the session
    $messages = @_ci.session.userdata('messages')
    if empty($messages) then 
      @clear()
      
    
  
  #  clear all messages
  clear :  ->
    $messages = {}
    for $type in @_types
      $messages[$type] = {}
      
    @_ci.session.set_userdata('messages', $messages)
    
  
  #  add a message, default type is message
  add : ($message, $type = 'message') ->
    if strlen($message) < 1 then return $messages = @_ci.session.userdata('messages')if is_a($message, 'PEAR_Error') then 
      $message = $message.getMessage()
      $type = 'error'
      else if not in_array($type, @_types) then 
      #  set the type to message if the user specified a type that's unknown
      $type = 'message'
      if not in_array($message, $messages[$type]) and is_string($message) then 
      $messages[$type].push $message
      $messages = @_ci.session.set_userdata('messages', $messages)}sum : ($type = null) ->
      $messages = @_ci.session.userdata('messages')
      if not empty($type) then 
        $i = count($messages[$type])
        return $i
        
      $i = 0
      for $type in @_types
        $i+=count($messages[$type])
        
      return $i
      get : ($type = null) ->
      $messages = @_ci.session.userdata('messages')
      if not empty($type) then 
        if count($messages[$type]) is 0 then 
          return false
          
        return $messages[$type]
        
      #  return false if there actually are no messages in the session
      $i = 0
      for $type in @_types
        $i+=count($messages[$type])
        
      if $i is 0 then 
        return false
        
      
      #  order return by order of type array above
      #  i.e. success, error, warning and then informational messages last
      for $type in @_types
        $return[$type] = $messages[$type]
        
      @clear()
      return $return
      }#  handle PEAR errors gracefully#  don't repeat messages!#  return messages of given type or all types, return false if none#  return messages of given type or all types, return false if none, clearing stack
module.exports = Messages