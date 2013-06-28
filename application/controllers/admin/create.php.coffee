#+--------------------------------------------------------------------+
#  create.coffee
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
class Create extends Controller
  
  Create :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.helper('file')
    @template.set('page_title', 'Create account')
    
    #  Form fields 
    $default_start = '01/04/'
    $default_end = '31/03/'
    if date('n') > 3 then 
      $default_start+=date('Y')
      $default_end+=date('Y') + 1
      else 
      $default_start+=date('Y') - 1
      $default_end+=date('Y')
      
    
    #  Form fields 
    $data['account_label'] = 
      'name':'account_label', 
      'id':'account_label', 
      'maxlength':'30', 
      'size':'30', 
      'value':'', 
      
    $data['account_name'] = 
      'name':'account_name', 
      'id':'account_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['account_address'] = 
      'name':'account_address', 
      'id':'account_address', 
      'rows':'4', 
      'cols':'47', 
      'value':'', 
      
    $data['account_email'] = 
      'name':'account_email', 
      'id':'account_email', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['fy_start'] = 
      'name':'fy_start', 
      'id':'fy_start', 
      'maxlength':'11', 
      'size':'11', 
      'value':$default_start, 
      
    $data['fy_end'] = 
      'name':'fy_end', 
      'id':'fy_end', 
      'maxlength':'11', 
      'size':'11', 
      'value':$default_end, 
      
    $data['account_currency'] = 
      'name':'account_currency', 
      'id':'account_currency', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['account_date_options'] = 
      'dd/mm/yyyy':'Day / Month / Year', 
      'mm/dd/yyyy':'Month / Day / Year', 
      'yyyy/mm/dd':'Year / Month / Day', 
      
    $data['account_date'] = 'dd/mm/yyyy'
    $data['account_timezone'] = 'UTC'
    
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
      
    $data['create_database'] = false
    
    #  Form validations 
    @validation.set_rules('account_label', 'Label', 'trim|required|min_length[2]|max_length[30]|alpha_numeric')
    @validation.set_rules('account_name', 'Account Name', 'trim|required|min_length[2]|max_length[100]')
    @validation.set_rules('account_address', 'Account Address', 'trim|max_length[255]')
    @validation.set_rules('account_email', 'Account Email', 'trim|valid_email')
    if $_POST then 
      @config.set_item('account_date_format', @input.post('account_date', true))
      @validation.set_rules('fy_start', 'Financial Year Start', 'trim|required|is_date')
      @validation.set_rules('fy_end', 'Financial Year End', 'trim|required|is_date')
      
    @validation.set_rules('account_currency', 'Currency', 'trim|max_length[10]')
    @validation.set_rules('account_date', 'Date', 'trim|max_length[10]')
    @validation.set_rules('account_timezone', 'Timezone', 'trim|max_length[6]')
    
    
    @validation.set_rules('database_name', 'Database Name', 'trim|required')
    @validation.set_rules('database_username', 'Database Username', 'trim|required')
    
    #  Repopulating form 
    if $_POST then 
      $data['account_label']['value'] = @input.post('account_label', true)
      $data['account_name']['value'] = @input.post('account_name', true)
      $data['account_address']['value'] = @input.post('account_address', true)
      $data['account_email']['value'] = @input.post('account_email', true)
      $data['fy_start']['value'] = @input.post('fy_start', true)
      $data['fy_end']['value'] = @input.post('fy_end', true)
      $data['account_currency']['value'] = @input.post('account_currency', true)
      $data['account_date'] = @input.post('account_date', true)
      $data['account_timezone'] = @input.post('account_timezone', true)
      
      $data['create_database'] = @input.post('create_database', true)
      $data['database_name']['value'] = @input.post('database_name', true)
      $data['database_username']['value'] = @input.post('database_username', true)
      $data['database_password']['value'] = @input.post('database_password', true)
      $data['database_host']['value'] = @input.post('database_host', true)
      $data['database_port']['value'] = @input.post('database_port', true)
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('admin_template', 'admin/create', $data)
      return 
      
    else 
      $data_account_label = @input.post('account_label', true)
      $data_account_label = strtolower($data_account_label)
      $data_account_name = @input.post('account_name', true)
      $data_account_address = @input.post('account_address', true)
      $data_account_email = @input.post('account_email', true)
      $data_fy_start = date_php_to_mysql(@input.post('fy_start', true))
      $data_fy_end = date_php_to_mysql_end_time(@input.post('fy_end', true))
      $data_account_currency = @input.post('account_currency', true)
      $data_account_date_form = @input.post('account_date', true)
      #  Checking for valid format 
      if $data_account_date_form is "dd/mm/yyyy" then $data_account_date = "dd/mm/yyyy"else if $data_account_date_form is "mm/dd/yyyy" then $data_account_date = "mm/dd/yyyy"else if $data_account_date_form is "yyyy/mm/dd" then $data_account_date = "yyyy/mm/dd"else #  Check if database ini file exists #  Check if start date is less than end date $data_account_date = "dd/mm/yyyy"$data_account_timezone = @input.post('timezones', true)$data_database_type = 'mysql'$data_database_host = @input.post('database_host', true)$data_database_port = @input.post('database_port', true)$data_database_name = @input.post('database_name', true)$data_database_username = @input.post('database_username', true)$data_database_password = @input.post('database_password', true)$ini_file = @config.item('config_path') + "accounts/" + $data_account_label + ".ini"if get_file_info($ini_file) then 
        @messages.add('Account with same label already exists.', 'error')
        @template.load('admin_template', 'admin/create', $data)
        return 
        if $data_fy_end<=$data_fy_start then 
        @messages.add('Financial start date cannot be greater than end date.', 'error')
        @template.load('admin_template', 'admin/create', $data)
        return 
        if $data_database_host is "" then $data_database_host = "localhost"if $data_database_port is "" then $data_database_port = "3306"if @input.post('create_database', true) is "1" then 
        $new_link = mysql_connect($data_database_host + ':' + $data_database_port, $data_database_username, $data_database_password)
        if $new_link then 
          #  Check if database already exists 
          $db_selected = mysql_select_db($data_database_name, $new_link)
          if $db_selected then 
            mysql_close($new_link)
            @messages.add('Database already exists.', 'error')
            @template.load('admin_template', 'admin/create', $data)
            return 
            
          
          #  Creating account database 
          $db_create_q = 'CREATE DATABASE ' + mysql_real_escape_string($data_database_name)
          if mysql_query($db_create_q, $new_link) then 
            @messages.add('Created account database.', 'success')
            else 
            @messages.add('Error creating account database. ' + mysql_error(), 'error')
            @template.load('admin_template', 'admin/create', $data)
            return 
            
          mysql_close($new_link)
          else 
          @messages.add('Error connecting to database. ' + mysql_error(), 'error')
          @template.load('admin_template', 'admin/create', $data)
          return 
          
        $dsn = "mysql://${data_database_username}:${data_database_password}@${data_database_host}:${data_database_port}/${data_database_name}"$newacc = @load.database($dsn, true)if not $newacc.conn_id then 
        @messages.add('Error connecting to database.', 'error')
        @template.load('admin_template', 'admin/create', $data)
        return 
        else if $newacc._error_message() isnt "" then 
        @messages.add('Error connecting to database. ' + $newacc._error_message(), 'error')
        @template.load('admin_template', 'admin/create', $data)
        return 
        else if $newacc.query("SHOW TABLES").num_rows() > 0 then 
        @messages.add('Selected database in not empty.', 'error')
        @template.load('admin_template', 'admin/create', $data)
        return 
        else 
        #  Executing the database setup script 
        $setup_account = read_file('system/application/controllers/admin/schema.sql')
        $setup_account_array = explode(";", $setup_account)
        for $row in $setup_account_array
          if strlen($row) < 5 then continue
          $newacc.query($row)
          if $newacc._error_message() isnt "" then 
            @messages.add('Error initializing account database.', 'error')
            @template.load('admin_template', 'admin/create', $data)
            return 
            
          
        @messages.add('Initialized account database.', 'success')
        
        #  Initial account setup 
        $setup_initial_data = read_file('system/application/controllers/admin/initialize.sql')
        $setup_initial_data_array = explode(";", $setup_initial_data)
        $newacc.trans_start()
        for $row in $setup_initial_data_array
          if strlen($row) < 5 then continue
          $newacc.query($row)
          if $newacc._error_message() isnt "" then 
            $newacc.trans_rollback()
            @messages.add('Error initializing basic accounts data.', 'error')
            @template.load('admin_template', 'admin/create', $data)
            return 
            
          
        $newacc.trans_complete()
        @messages.add('Initialized basic accounts data.', 'success')
        
        #  Adding account settings 
        $newacc.trans_start()
        if not $newacc.query("INSERT INTO settings (id, name, address, email, fy_start, fy_end, currency_symbol, date_format, timezone, manage_inventory, account_locked, email_protocol, email_host, email_port, email_username, email_password, print_paper_height, print_paper_width, print_margin_top, print_margin_bottom, print_margin_left, print_margin_right, print_orientation, print_page_format, database_version) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [1, $data_account_name, $data_account_address, $data_account_email, $data_fy_start, $data_fy_end, $data_account_currency, $data_account_date, $data_account_timezone, 0, 0, '', '', 0, '', '', 0, 0, 0, 0, 0, 0, '', '', 4]) then 
          $newacc.trans_rollback()
          @messages.add('Error adding account settings.', 'error')
          @template.load('admin_template', 'admin/create', $data)
          return 
          else 
          $newacc.trans_complete()
          @messages.add('Added account settings.', 'success')
          
        
        #  Adding account settings to file. Code copied from manage controller 
        $con_details = "[database]" + "\r\n" + "db_type = \"" + $data_database_type + "\"" + "\r\n" + "db_hostname = \"" + $data_database_host + "\"" + "\r\n" + "db_port = \"" + $data_database_port + "\"" + "\r\n" + "db_name = \"" + $data_database_name + "\"" + "\r\n" + "db_username = \"" + $data_database_username + "\"" + "\r\n" + "db_password = \"" + $data_database_password + "\"" + "\r\n"
        
        $con_details_html = '[database]' + '<br />db_type = "' + $data_database_type + '"<br />db_hostname = "' + $data_database_host + '"<br />db_port = "' + $data_database_port + '"<br />db_name = "' + $data_database_name + '"<br />db_username = "' + $data_database_username + '"<br />db_password = "' + $data_database_password + '"<br />'
        
        #  Writing the connection string to end of file - writing in 'a' append mode 
        if not write_file($ini_file, $con_details) then 
          @messages.add('Failed to create account settings file. Check if "' + $ini_file + '" file is writable.', 'error')
          @messages.add('You can manually create a text file "' + $ini_file + '" with the following content :<br /><br />' + $con_details_html, 'error')
          else 
          @messages.add('Added account settings file to list of active accounts.', 'success')
          
        
        redirect('admin')
        return 
        }return }}#  Creating account database #  Setting database #  End of file create.php #  Location: ./system/application/controllers/admin/create.php 
module.exports = Create