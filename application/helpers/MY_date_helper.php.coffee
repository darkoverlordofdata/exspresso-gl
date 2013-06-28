#+--------------------------------------------------------------------+
#  MY_date_helper.coffee
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

if not function_exists('date_php_to_mysql') then 
  exports.date_php_to_mysql = date_php_to_mysql = ($dt) ->
    $CI = get_instance()
    $current_date_format = $CI.config.item('account_date_format')
    [$d, $m, $y] = [0, 0, 0]
    switch $current_date_format
      when 'dd/mm/yyyy'
        [$d, $m, $y] = explode('/', $dt)
        
      when 'mm/dd/yyyy'
        [$m, $d, $y] = explode('/', $dt)
        
      when 'yyyy/mm/dd'
        [$y, $m, $d] = explode('/', $dt)
        
      else
        $CI.messages.add('Invalid date format. Check your account settings.', 'error')
        return ""
        
    $ts = mktime(0, 0, 0, $m, $d, $y)
    return date('Y-m-d H:i:s', $ts)
    
  

if not function_exists('date_php_to_mysql_end_time') then 
  exports.date_php_to_mysql_end_time = date_php_to_mysql_end_time = ($dt) ->
    $CI = get_instance()
    $current_date_format = $CI.config.item('account_date_format')
    [$d, $m, $y] = [0, 0, 0]
    switch $current_date_format
      when 'dd/mm/yyyy'
        [$d, $m, $y] = explode('/', $dt)
        
      when 'mm/dd/yyyy'
        [$m, $d, $y] = explode('/', $dt)
        
      when 'yyyy/mm/dd'
        [$y, $m, $d] = explode('/', $dt)
        
      else
        $CI.messages.add('Invalid date format. Check your account settings.', 'error')
        return ""
        
    $ts = mktime("23", "59", "59", $m, $d, $y)
    return date('Y-m-d H:i:s', $ts)
    
  

if not function_exists('date_mysql_to_php') then 
  exports.date_mysql_to_php = date_mysql_to_php = ($dt) ->
    $ts = human_to_unix($dt)
    $CI = get_instance()
    $current_date_format = $CI.config.item('account_date_format')
    switch $current_date_format
      when 'dd/mm/yyyy'
        return date('d/m/Y', $ts)
        
      when 'mm/dd/yyyy'
        return date('m/d/Y', $ts)
        
      when 'yyyy/mm/dd'
        return date('Y/m/d', $ts)
        
      else
        $CI.messages.add('Invalid date format. Check your account settings.', 'error')
        return ""
        
    return 
    
  

if not function_exists('date_mysql_to_timestamp') then 
  exports.date_mysql_to_timestamp = date_mysql_to_timestamp = ($dt) ->
    return strtotime($dt)
    
  

if not function_exists('date_mysql_to_php_display') then 
  exports.date_mysql_to_php_display = date_mysql_to_php_display = ($dt) ->
    $ts = human_to_unix($dt)
    $CI = get_instance()
    $current_date_format = $CI.config.item('account_date_format')
    switch $current_date_format
      when 'dd/mm/yyyy'
        return date('d M Y', $ts)
        
      when 'mm/dd/yyyy'
        return date('M d Y', $ts)
        
      when 'yyyy/mm/dd'
        return date('Y M d', $ts)
        
      else
        $CI.messages.add('Invalid date format. Check your account settings.', 'error')
        return ""
        
    return 
    
  

if not function_exists('date_today_php') then 
  exports.date_today_php = date_today_php =  ->
    $CI = get_instance()
    
    #  Check for date beyond the current financial year range 
    $todays_date = date('Y-m-d 00:00:00')
    $fy_start = $CI.config.item('account_fy_start')
    $fy_end = $CI.config.item('account_fy_end')
    if $CI.config.item('account_fy_start') > $todays_date then return date_mysql_to_php($fy_start)if $CI.config.item('account_fy_end') < $todays_date then return date_mysql_to_php($fy_end)$current_date_format = $CI.config.item('account_date_format')switch $current_date_format
      when 'dd/mm/yyyy'
        return date('d/m/Y')
        
      when 'mm/dd/yyyy'
        return date('m/d/Y')
        
      when 'yyyy/mm/dd'
        return date('Y/m/d')
        
      else
        $CI.messages.add('Invalid date format. Check your account settings.', 'error')
        return ""
        return }}#  End of file date_helper.php #  Location: ./system/application/helpers/date_helper.php 