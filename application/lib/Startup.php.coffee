#+--------------------------------------------------------------------+
#  Startup.coffee
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

#
# Startup:: a class that is loaded everytime the application is accessed
#
# Setup all the initialization routines that the application uses in this
# class. It is autoloaded evertime the application is accessed.
#
#



class Startup

  #
  # Phase I
  #
  #   POC ONLY: Make the not-php api global
  #
  not_php = require('not-php')
  for $name, $body of not_php
    not_php.define $name, $body, global

  constructor: (@controller, $config = {}) ->
    @db.trans_strict(false)
    @load.library('general')
    
    #  Skip checking if accessing admin section
    if @uri.segment(1) is "admin" then return if @uri.segment(1) is "update" then return if @uri.segment(1) is "user" then return if not @session.userdata('user_name')
      @redirect('user/login')
      return 
    if @session.userdata('active_account')
      #  Fetching database label details from session and checking the database ini file
      if not $active_account = @general.check_account(@session.userdata('active_account'))) then @session.unset_userdata('active_account')
        @redirect('user/account')
        return


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
    @load.database($db_config, false, true)

    #  Checking for valid database connection
    if not @db.conn_id
      @session.unset_userdata('active_account')
      @messages.add('Error connecting to database server. Check whether database server is running.', 'error')
      @redirect('user/account')
      return

    #  Check for any database connection error messages
    if @db._error_message() isnt ""
      @session.unset_userdata('active_account')
      @messages.add('Error connecting to database server. ' + @db._error_message(), 'error')
      @redirect('user/account')
      return

    else
      @messages.add('Select a account.', 'error')
      @redirect('user/account')
      return
    if not @general.check_database()
      @session.unset_userdata('active_account')
      @redirect('user/account')
      return

    @db.from('settings').where('id', 1).limit(1)#  Check if user is logged in #  Reading database settings ini file #  Checking for valid database connection #  Loading account data
    $account_q = @db.get()
    if not ($account_d = $account_q.row())
      @messages.add('Invalid account settings.', 'error')
      @redirect('user/account')
      return
    @config.set_item('account_name', $account_d.name)#  Skip checking if accessing user section@config.set_item('account_address', $account_d.address)#  Skip checking if accessing updated page
    @config.set_item('account_email', $account_d.email)
    @config.set_item('account_fy_start', $account_d.fy_start)
    @config.set_item('account_fy_end', $account_d.fy_end)
    @config.set_item('account_currency_symbol', $account_d.currency_symbol)
    @config.set_item('account_date_format', $account_d.date_format)
    @config.set_item('account_timezone', $account_d.timezone)
    @config.set_item('account_locked', $account_d.account_locked)
    @config.set_item('account_database_version', $account_d.database_version)
    
    #  Load general application settings 
    @general.check_setting()
    
    #  Load entry types 
    @general.setup_entry_types()
    
    return 
    
  
module.exports = Startup

#  End of file startup.php 
#  Location: ./system/application/libraries/startup.php 
