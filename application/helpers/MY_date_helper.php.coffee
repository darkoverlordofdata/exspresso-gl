#+--------------------------------------------------------------------+
#  MY_date_helper.coffee
#+--------------------------------------------------------------------+
#  Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#
#  This file is a part of Exspresso-GL
#
#  Exspresso is free software you can copy, modify, and distribute
#  it under the terms of the MIT License
#
#+--------------------------------------------------------------------+
#

#

exports.date_php_to_mysql = date_php_to_mysql = ($dt) ->
  $current_date_format = @config.item('account_date_format')
  [$d, $m, $y] = [0, 0, 0]
  switch $current_date_format
    when 'dd/mm/yyyy'
      [$d, $m, $y] = explode('/', $dt)

    when 'mm/dd/yyyy'
      [$m, $d, $y] = explode('/', $dt)

    when 'yyyy/mm/dd'
      [$y, $m, $d] = explode('/', $dt)

    else
      @messages.add('Invalid date format. Check your account settings.', 'error')
      return ""

  $ts = mktime(0, 0, 0, $m, $d, $y)
  return date('Y-m-d H:i:s', $ts)



exports.date_php_to_mysql_end_time = date_php_to_mysql_end_time = ($dt) ->
  $current_date_format = @config.item('account_date_format')
  [$d, $m, $y] = [0, 0, 0]
  switch $current_date_format
    when 'dd/mm/yyyy'
      [$d, $m, $y] = explode('/', $dt)

    when 'mm/dd/yyyy'
      [$m, $d, $y] = explode('/', $dt)

    when 'yyyy/mm/dd'
      [$y, $m, $d] = explode('/', $dt)

    else
      @messages.add('Invalid date format. Check your account settings.', 'error')
      return ""

  $ts = mktime("23", "59", "59", $m, $d, $y)
  return date('Y-m-d H:i:s', $ts)



exports.date_mysql_to_php = date_mysql_to_php = ($dt) ->
  $ts = human_to_unix($dt)
  $current_date_format = @config.item('account_date_format')
  switch $current_date_format
    when 'dd/mm/yyyy'
      return date('d/m/Y', $ts)

    when 'mm/dd/yyyy'
      return date('m/d/Y', $ts)

    when 'yyyy/mm/dd'
      return date('Y/m/d', $ts)

    else
      @messages.add('Invalid date format. Check your account settings.', 'error')
      return ""

  return



exports.date_mysql_to_timestamp = date_mysql_to_timestamp = ($dt) ->
  return strtotime($dt)



exports.date_mysql_to_php_display = date_mysql_to_php_display = ($dt) ->
  $ts = human_to_unix($dt)
  $current_date_format = @config.item('account_date_format')
  switch $current_date_format
    when 'dd/mm/yyyy'
      return date('d M Y', $ts)

    when 'mm/dd/yyyy'
      return date('M d Y', $ts)

    when 'yyyy/mm/dd'
      return date('Y M d', $ts)

    else
      @messages.add('Invalid date format. Check your account settings.', 'error')
      return ""

  return



exports.date_today_php = date_today_php =  ->

  #  Check for date beyond the current financial year range
  $todays_date = date('Y-m-d 00:00:00')
  $fy_start = @config.item('account_fy_start')
  $fy_end = @config.item('account_fy_end')
  if @config.item('account_fy_start') > $todays_date then return date_mysql_to_php($fy_start)if @config.item('account_fy_end') < $todays_date then return date_mysql_to_php($fy_end)$current_date_format = @config.item('account_date_format')switch $current_date_format
    when 'dd/mm/yyyy'
      return date('d/m/Y')

    when 'mm/dd/yyyy'
      return date('m/d/Y')

    when 'yyyy/mm/dd'
      return date('Y/m/d')

    else
      @messages.add('Invalid date format. Check your account settings.', 'error')
      return ""
    return

#  End of file date_helper.php #  Location: ./system/application/helpers/date_helper.php