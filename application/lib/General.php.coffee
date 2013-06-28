#+--------------------------------------------------------------------+
#  General.coffee
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

module.exports = class General

  error_messages: null

  constructor: (@controller, $config = {}) ->
    @error_messages = {}
  

  #  Check format of config/accounts ini files 
  check_account: ($account_name) ->
    
    $ini_file = @config.item('config_path') + "accounts/" + $account_name + ".ini"
    
    #  Check if database ini file exists 
    if not get_file_info($ini_file) then 
      @messages.add('Account settings file is missing.', 'error')
      return false
      
    
    #  Parsing database ini file 
    $account_data = parse_ini_file($ini_file)
    if not $account_data then 
      @messages.add('Invalid account settings.', 'error')
      return false
      
    
    #  Check if all needed variables are set in ini file 
    if not $account_data['db_hostname']?  then 
      @messages.add('Hostname missing from account settings file.', 'error')
      return false
      
    if not $account_data['db_port']?  then 
      @messages.add('Port missing from account setting file. Default MySQL port is 3306.', 'error')
      return false
      
    if not $account_data['db_name']?  then 
      @messages.add('Database name missing from account setting file.', 'error')
      return false
      
    if not $account_data['db_username']?  then 
      @messages.add('Database username missing from account setting file.', 'error')
      return false
      
    if not $account_data['db_password']?  then 
      @messages.add('Database password missing from account setting file.', 'error')
      return false
      
    return $account_data
    
  
  #  Check for valid account database 
  check_database :  ->

    #  Checking for valid database connection 
    if @db.conn_id then 
      #  Checking for valid database name, username, password 
      if @db.query("SHOW TABLES") then 
        #  Check for valid webzash database 
        if @uri.segment(1) isnt "update" then 
          #  check for valid settings table 
          $valid_settings_q = mysql_query('DESC settings')
          if not $valid_settings_q then 
            @messages.add('Invalid account database. Table "settings" missing.', 'error')
            return false
            
          @check_database_version()
          
          $table_names = ['groups', 'ledgers', 'entry_types', 'entries', 'entry_items', 'tags', 'logs', 'settings']
          for $id, $tbname of $table_names
            $valid_db_q = mysql_query('DESC ' + $tbname)
            if not $valid_db_q then 
              @messages.add('Invalid account database. Table "' + $tbname + '" missing.', 'error')
              return false
              
            
          
        else 
        @messages.add('Invalid database connection settings. Check whether the provided database name, username and password are valid.', 'error')
        return false
        
      else 
      @messages.add('Cannot connect to database server. Check whether database server is running.', 'error')
      return false
      
    return true
    
  
  #  Check config/settings/general.ini file 
  check_setting :  ->

    $setting_ini_file = @config.item('config_path') + "settings/general.ini"
    
    #  Set default values 
    @config.set_item('row_count', "20")
    @config.set_item('log', "1")
    
    #  Check if general application settings ini file exists 
    if get_file_info($setting_ini_file) then 
      #  Parsing general application settings ini file 
      $cur_setting = parse_ini_file($setting_ini_file)
      if $cur_setting then 
        if $cur_setting['row_count']?  then 
          @config.set_item('row_count', $cur_setting['row_count'])
          
        if $cur_setting['log']?  then 
          @config.set_item('log', $cur_setting['log'])
          
        
      
    
  
  check_user : ($user_name) ->

    #  User validation 
    $ini_file = @config.item('config_path') + "users/" + $user_name + ".ini"
    
    #  Check if user ini file exists 
    if not get_file_info($ini_file) then 
      @messages.add('User does not exists.', 'error')
      return false
      
    
    #  Parsing user ini file 
    $user_data = parse_ini_file($ini_file)
    if not $user_data then 
      @messages.add('Invalid user file.', 'error')
      return false
      
    
    if not $user_data['username']?  then 
      @messages.add('Username missing from user file.', 'error')
      return false
      
    if not $user_data['password']?  then 
      @messages.add('Password missing from user file.', 'error')
      return false
      
    if not $user_data['status']?  then 
      @messages.add('Status missing from user file.', 'error')
      return false
      
    if not $user_data['role']?  then 
      @messages.add('Role missing from user file. Defaulting to "guest" role.', 'error')
      $user_data['role'] = 'guest'
      
    if not $user_data['accounts']?  then 
      @messages.add('Accounts missing from user file.', 'error')
      
    return $user_data
    
  
  check_database_version :  ->

    if @uri.segment(1) is "update" then return @db.from('settings').where('id', 1).limit(1)#  Loading account data
    $account_q = @db.get()
    if not ($account_d = $account_q.row()) then 
      @messages.add('Invalid account settings.', 'error')
      redirect('user/account')
      return 
      
    
    if $account_d.database_version < @config.item('required_database_version') then 
      @messages.add('You need to updated the account database before continuing. Click ' + anchor('update', 'here', 'ttile':'Click here to update account database') + ' to update.', 'error')
      redirect('user/account')
      return 
      else if $account_d.database_version > @config.item('required_database_version') then 
      @messages.add('You need to updated the application version from <a href="http://webzash.org" target="_blank">http://webzash.org<a/> before continuing.', 'error')
      redirect('user/account')
      return 
      
    
  
  setup_entry_types :  ->

    @db.from('entry_types').order_by('id', 'asc')
    $entry_types = @db.get()
    if $entry_types.num_rows() < 1 then 
      @messages.add('You need to create a entry type before you can create any entries.', 'error')
      
    $entry_type_config = {}
    for $id, $row of $entry_types.result()
      $entry_type_config[$row.id] = 
        'label':$row.label, 
        'name':$row.name, 
        'description':$row.description, 
        'base_type':$row.base_type, 
        'numbering':$row.numbering, 
        'prefix':$row.prefix, 
        'suffix':$row.suffix, 
        'zero_padding':$row.zero_padding, 
        'bank_cash_ledger_restriction':$row.bank_cash_ledger_restriction, 
        
      
    @config.set_item('account_entry_types', $entry_type_config)
    
  
module.exports = General

#  End of file General.php 
#  Location: ./system/application/libraries/General.php 
