#+--------------------------------------------------------------------+
#  Startup.coffee
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
# Startup:: a class that is loaded everytime the application is accessed
#
# Setup all the initialization routines that the application uses in this
# class. It is autoloaded evertime the application is accessed.
#
#

class Startup

  Startup :  ->
    $CI = get_instance()
    $CI.db.trans_strict(false)
    $CI.load.library('general')
    
    #  Skip checking if accessing admin section
    if $CI.uri.segment(1) is "admin" then return if $CI.uri.segment(1) is "update" then return if $CI.uri.segment(1) is "user" then return if not $CI.session.userdata('user_name') then 
      redirect('user/login')
      return 
      if $CI.session.userdata('active_account') then 
      #  Fetching database label details from session and checking the database ini file 
      if not $active_account = $CI.general.check_account($CI.session.userdata('active_account'))) then $CI.session.unset_userdata('active_account')
      redirect('user/account')
      return 
      }
      
      #  Preparing database settings 
      $db_config['hostname'] = $active_account['db_hostname']
      $db_config['hostname']+=":" + $active_account['db_port']
      $db_config['database'] = $active_account['db_name']
      $db_config['username'] = $active_account['db_username']
      $db_config['password'] = $active_account['db_password']
      $db_config['dbdriver'] = "mysql"
      $db_config['dbprefix'] = ""
      $db_config['pconnect'] = false
      $db_config['db_debug'] = false
      $db_config['cache_on'] = false
      $db_config['cachedir'] = ""
      $db_config['char_set'] = "utf8"
      $db_config['dbcollat'] = "utf8_general_ci"
      $CI.load.database($db_config, false, true)
      
      #  Checking for valid database connection 
      if not $CI.db.conn_id then 
        $CI.session.unset_userdata('active_account')
        $CI.messages.add('Error connecting to database server. Check whether database server is running.', 'error')
        redirect('user/account')
        return 
        
      #  Check for any database connection error messages 
      if $CI.db._error_message() isnt "" then 
        $CI.session.unset_userdata('active_account')
        $CI.messages.add('Error connecting to database server. ' + $CI.db._error_message(), 'error')
        redirect('user/account')
        return 
        
      else 
      $CI.messages.add('Select a account.', 'error')
      redirect('user/account')
      return 
      if not $CI.general.check_database() then 
      $CI.session.unset_userdata('active_account')
      redirect('user/account')
      return 
      $CI.db.from('settings').where('id', 1).limit(1)#  Check if user is logged in #  Reading database settings ini file #  Checking for valid database connection #  Loading account data $account_q = $CI.db.get()if not ($account_d = $account_q.row()) then 
      $CI.messages.add('Invalid account settings.', 'error')
      redirect('user/account')
      return 
      $CI.config.set_item('account_name', $account_d.name)#  Skip checking if accessing user section$CI.config.set_item('account_address', $account_d.address)#  Skip checking if accessing updated page 
    $CI.config.set_item('account_email', $account_d.email)
    $CI.config.set_item('account_fy_start', $account_d.fy_start)
    $CI.config.set_item('account_fy_end', $account_d.fy_end)
    $CI.config.set_item('account_currency_symbol', $account_d.currency_symbol)
    $CI.config.set_item('account_date_format', $account_d.date_format)
    $CI.config.set_item('account_timezone', $account_d.timezone)
    $CI.config.set_item('account_locked', $account_d.account_locked)
    $CI.config.set_item('account_database_version', $account_d.database_version)
    
    #  Load general application settings 
    $CI.general.check_setting()
    
    #  Load entry types 
    $CI.general.setup_entry_types()
    
    return 
    
  
module.exports = Startup

#  End of file startup.php 
#  Location: ./system/application/libraries/startup.php 
