#+--------------------------------------------------------------------+
#  Logger.coffee
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

class Logger

  Logger :  ->
    return 
    
  
  #
  # Write message to database log
  # Levels defined are :
  # 0 - error
  # 1 - success
  # 2 - info
  # 3 - debug
  #
  write_message : ($level = "debug", $title = "", $desc = "") ->
    $CI = get_instance()
    
    #  Check if logging is enabled. Skip if it is not enabled 
    if $CI.config.item('log') isnt "1" then return $data['date'] = date("Y-m-d H:i:s")$data['level'] = 3switch $level
      when "error"$data['level'] = 0
      when "success"$data['level'] = 1
      when "info"$data['level'] = 2
      when "debug"$data['level'] = 3
      else$data['level'] = 0
        $data['host_ip'] = $CI.input.ip_address()$data['user'] = $CI.session.userdata('user_name')$data['url'] = uri_string()$data['user_agent'] = $CI.input.user_agent()$data['message_title'] = $title$data['message_desc'] = $desc$CI.db.insert('logs', $data)
    return 
    
  
  read_recent_messages :  ->
    $CI = get_instance()
    $CI.db.from('logs').order_by('id', 'desc').limit(20)
    $logs_q = $CI.db.get()
    if $logs_q.num_rows() > 0 then 
      return $logs_q
      else 
      return false
      
    
  
module.exports = Logger

