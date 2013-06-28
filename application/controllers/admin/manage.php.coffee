#+--------------------------------------------------------------------+
#  manage.coffee
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
class Manage extends Controller
  
  Manage :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.helper('file')
    @template.set('page_title', 'Manage accounts')
    @template.set('nav_links', 'admin/manage/add':'New account')
    
    #  Getting list of files in the config - accounts directory 
    $accounts_list = get_filenames(@config.item('config_path') + 'accounts')
    $data['accounts'] = {}
    if $accounts_list then 
      for $row in $accounts_list
        #  Only include file ending with .ini 
        if substr($row,  - 4) is ".ini" then 
          $ini_label = substr($row, 0,  - 4)
          $data['accounts'][$ini_label] = $ini_label
          
        
      
    
    @template.load('admin_template', 'admin/manage/index', $data)
    return 
    
  
  add :  ->
    @template.set('page_title', 'Add account')
    
    #  Form fields 
    $data['database_label'] = 
      'name':'database_label', 
      'id':'database_label', 
      'maxlength':'30', 
      'size':'30', 
      'value':'', 
      
    
    $data['database_name'] = 
      'name':'database_name', 
      'id':'database_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_username'] = 
      'name':'database_username', 
      'id':'database_username', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_password'] = 
      'name':'database_password', 
      'id':'database_password', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_host'] = 
      'name':'database_host', 
      'id':'database_host', 
      'maxlength':'100', 
      'size':'40', 
      'value':'localhost', 
      
    
    $data['database_port'] = 
      'name':'database_port', 
      'id':'database_port', 
      'maxlength':'100', 
      'size':'40', 
      'value':'3306', 
      
    
    #  Repopulating form 
    if $_POST then 
      $data['database_label']['value'] = @input.post('database_label', true)
      $data['database_name']['value'] = @input.post('database_name', true)
      $data['database_username']['value'] = @input.post('database_username', true)
      $data['database_password']['value'] = @input.post('database_password', true)
      $data['database_host']['value'] = @input.post('database_host', true)
      $data['database_port']['value'] = @input.post('database_port', true)
      
    
    #  Form validations 
    @validation.set_rules('database_label', 'Label', 'trim|required|min_length[2]|max_length[30]|alpha_numeric')
    @validation.set_rules('database_name', 'Database Name', 'trim|required')
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('admin_template', 'admin/manage/add', $data)
      return 
      
    else 
      $data_database_label = @input.post('database_label', true)
      $data_database_label = strtolower($data_database_label)
      $data_database_type = 'mysql'
      $data_database_host = @input.post('database_host', true)
      $data_database_port = @input.post('database_port', true)
      $data_database_name = @input.post('database_name', true)
      $data_database_username = @input.post('database_username', true)
      $data_database_password = @input.post('database_password', true)
      
      $ini_file = @config.item('config_path') + "accounts/" + $data_database_label + ".ini"
      
      #  Check if database ini file exists 
      if get_file_info($ini_file) then 
        @messages.add('Account with same label already exists.', 'error')
        @template.load('admin_template', 'admin/manage/add', $data)
        return 
        
      
      $con_details = "[database]" + "\r\n" + "db_type = \"" + $data_database_type + "\"" + "\r\n" + "db_hostname = \"" + $data_database_host + "\"" + "\r\n" + "db_port = \"" + $data_database_port + "\"" + "\r\n" + "db_name = \"" + $data_database_name + "\"" + "\r\n" + "db_username = \"" + $data_database_username + "\"" + "\r\n" + "db_password = \"" + $data_database_password + "\"" + "\r\n"
      
      $con_details_html = '[database]' + '<br />db_type = "' + $data_database_type + '"<br />db_hostname = "' + $data_database_host + '"<br />db_port = "' + $data_database_port + '"<br />db_name = "' + $data_database_name + '"<br />db_username = "' + $data_database_username + '"<br />db_password = "' + $data_database_password + '"<br />'
      
      #  Writing the connection string to end of file - writing in 'a' append mode 
      if not write_file($ini_file, $con_details) then 
        @messages.add('Failed to add account settings file. Check if "' + $ini_file + '" file is writable.', 'error')
        @messages.add('You can manually create a text file "' + $ini_file + '" with the following content :<br /><br />' + $con_details_html, 'error')
        @template.load('admin_template', 'admin/manage/add', $data)
        return 
        else 
        @messages.add('Added account to list of active accounts.', 'success')
        redirect('admin/manage')
        return 
        
      
    return 
    
  
  edit : ($database_label) ->
    @template.set('page_title', 'Edit account')
    
    $ini_file = @config.item('config_path') + "accounts/" + $database_label + ".ini"
    
    #  Form fields 
    $data['database_name'] = 
      'name':'database_name', 
      'id':'database_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_username'] = 
      'name':'database_username', 
      'id':'database_username', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_password'] = 
      'name':'database_password', 
      'id':'database_password', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_host'] = 
      'name':'database_host', 
      'id':'database_host', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['database_port'] = 
      'name':'database_port', 
      'id':'database_port', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['database_label'] = $database_label
    
    #  Repopulating form 
    if $_POST then 
      $data['database_host']['value'] = @input.post('database_host', true)
      $data['database_port']['value'] = @input.post('database_port', true)
      $data['database_name']['value'] = @input.post('database_name', true)
      $data['database_username']['value'] = @input.post('database_username', true)
      $data['database_password']['value'] = @input.post('database_password', true)
      else 
      #  Check if database ini file exists 
      if not get_file_info($ini_file) then 
        @messages.add('Account settings file labeled ' + $database_label + ' does not exists.', 'error')
        redirect('admin/manage')
        return 
        else 
        #  Parsing database ini file 
        $active_accounts = parse_ini_file($ini_file)
        if not $active_accounts then 
          $CI.messages.add('Invalid account settings file', 'error')
          else 
          #  Check if all needed variables are set in ini file 
          if $active_accounts['db_hostname']?  then $data['database_host']['value'] = $active_accounts['db_hostname']else $CI.messages.add('Hostname missing from account settings file', 'error')if $active_accounts['db_port']?  then $data['database_port']['value'] = $active_accounts['db_port']else $CI.messages.add('Port missing from account settings file. Default MySQL port is 3306', 'error')if $active_accounts['db_name']?  then $data['database_name']['value'] = $active_accounts['db_name']else $CI.messages.add('Database name missing from account settings file', 'error')if $active_accounts['db_username']?  then $data['database_username']['value'] = $active_accounts['db_username']else $CI.messages.add('Database username missing from account settings file', 'error')if not $active_accounts['db_password']?  then $CI.messages.add('Database password missing from account settings file', 'error')}}}@validation.set_rules('database_name', 'Database Name', 'trim|required')#  Form validations if @validation.run() is false then
            @messages.add(validation_errors(), 'error')
            @template.load('admin_template', 'admin/manage/edit', $data)
            return 
            else 
            $data_database_type = 'mysql'
            $data_database_host = @input.post('database_host', true)
            $data_database_port = @input.post('database_port', true)
            $data_database_name = @input.post('database_name', true)
            $data_database_username = @input.post('database_username', true)
            $data_database_password = @input.post('database_password', true)
            
            $ini_file = @config.item('config_path') + "accounts/" + $database_label + ".ini"
            
            $con_details = "[database]" + "\r\n" + "db_type = \"" + $data_database_type + "\"" + "\r\n" + "db_hostname = \"" + $data_database_host + "\"" + "\r\n" + "db_port = \"" + $data_database_port + "\"" + "\r\n" + "db_name = \"" + $data_database_name + "\"" + "\r\n" + "db_username = \"" + $data_database_username + "\"" + "\r\n" + "db_password = \"" + $data_database_password + "\"" + "\r\n"
            
            $con_details_html = '[database]' + '<br />db_type = "' + $data_database_type + '"<br />db_hostname = "' + $data_database_host + '"<br />db_port = "' + $data_database_port + '"<br />db_name = "' + $data_database_name + '"<br />db_username = "' + $data_database_username + '"<br />db_password = "' + $data_database_password + '"<br />'
            
            #  Writing the connection string to end of file - writing in 'a' append mode 
            if not write_file($ini_file, $con_details) then 
              @messages.add('Failed to edit account settings file. Check if "' + $ini_file + '" file is writable.', 'error')
              @messages.add('You can manually update the text file "' + $ini_file + '" with the following content :<br /><br />' + $con_details_html, 'error')
              @template.load('admin_template', 'admin/manage/edit', $data)
              return 
              else 
              @messages.add('Updated account settings.', 'success')
              redirect('admin/manage')
              return 
              
            return }delete : ($database_label) ->
            @template.set('page_title', 'Delete account')
            
            $ini_file = @config.item('config_path') + "accounts/" + $database_label + ".ini"
            @messages.add('Delete ' + $ini_file + ' file manually.', 'error')
            @messages.add('Only the settings file will be delete. Account database will have to be deleted manually.', 'status')
            redirect('admin/manage')
            return 
            }#  Validating form #  End of file manage.php #  Location: ./system/application/controllers/admin/manage.php 
module.exports = Manage