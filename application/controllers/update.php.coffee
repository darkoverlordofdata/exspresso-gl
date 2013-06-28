#+--------------------------------------------------------------------+
#  update.coffee
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

module.exports = class Update extends system.core.Controller
  
  indexAction:  ->
    @load.library('general')
    
    #  Common functionality from Startup library 
    
    #  Reading database settings ini file 
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
      
    
    #  Loading account data 
    @db.from('settings').where('id', 1).limit(1)
    $account_q = @db.get()
    if not ($account_d = $account_q.row())
      @messages.add('Invalid account settings.', 'error')
      @redirect('user/account')
      return 
      
    $data['account'] = $account_d
    @config.set_item('account_date_format', $account_d.date_format)
    
    $cur_db_version = $account_d.database_version
    $required_db_version = @config.item('required_database_version')
    
    if @input.post()
      while $cur_db_version < $required_db_version
        $cur_db_version+=1
        #  calling update function as object method 
        if not call_user_func([@, '_update_to_db_version_' + $cur_db_version]) then 
          @redirect('update/index')
          return 
          
        
      @messages.add('Done updating account database. Click ' + anchor('', 'here', 'title':'Click here to go back to accounts') + ' to go back to accounts.', 'success')
      @redirect('update/index')
      return 
      
    @template.load('user_template', 'update/index', $data)
    return 
    
  
  _update_to_db_version_4 :  ->
    $update_account = 
      """
        RENAME TABLE voucher_types TO entry_types;
        RENAME TABLE voucher_items TO entry_items;
        RENAME TABLE vouchers TO entries;
        ALTER TABLE entry_items CHANGE voucher_id entry_id INT(11) NOT NULL;
        ALTER TABLE entries CHANGE voucher_type entry_type INT(5) NOT NULL;
        ALTER TABLE settings CHANGE manage_stocks manage_inventory INT(1) NOT NULL;
        UPDATE ledgers SET type = '1' WHERE type = 'B';
        UPDATE ledgers SET type = '0' WHERE type = 'N';
        ALTER TABLE ledgers CHANGE type type INT(2) NOT NULL DEFAULT '0';
        ALTER TABLE entry_types CHANGE bank_cash_ledger_restriction bank_cash_ledger_restriction INT(2) NOT NULL DEFAULT 1;
      """
    
    $update_account_array = $update_account.split(";")
    for $row in $update_account_array
      if $row.length < 5 then continue
      @db.query($row)
      if @db._error_message() isnt ""
        @messages.add('Error updating account database. ' + @db._error_message(), 'error')
        return false
        
      
    #  Updating version number 
    $update_data = 
      'database_version':4, 
      
    if not @db.where('id', 1).update('settings', $update_data)
      @messages.add('Error updating settings table with correct database version.', 'error')
      return false
      
    @messages.add('Updated database version to 4.', 'success')
    return true
    
  
module.exports = Update

#  End of file update.php 
#  Location: ./system/application/controllers/update.php 
