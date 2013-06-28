#+--------------------------------------------------------------------+
#  cf.coffee
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
class Cf extends Controller
  
  Cf :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.helper('file')
    @load.library('accountlist')
    @load.model('Ledger_model')
    @load.model('Setting_model')
    @template.set('page_title', 'Carry forward account')
    
    #  Check access 
    if not check_access('cf account') then 
      @messages.add('Permission denied.', 'error')
      redirect('setting')
      return 
      
    
    #  Current settings 
    $account_data = @Setting_model.get_current()
    
    #  Form fields 
    $last_year_end = @config.item('account_fy_end')
    [$last_year_end_date, $last_year_end_time] = explode(' ', $last_year_end)
    [$last_year_end_year, $last_year_end_month, $last_year_end_day] = explode('-', $last_year_end_date)
    $last_year_end_ts = strtotime($last_year_end)
    $default_start_ts = $last_year_end_ts + (60 * 60 * 24)#  Adding 24 hours 
    $default_start = date("Y-m-d 00:00:00", $default_start_ts)
    $default_end = ($last_year_end_year + 1) + "-" + $last_year_end_month + "-" + $last_year_end_day + " 00:00:00"
    
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
      
    $data['fy_start'] = 
      'name':'fy_start', 
      'id':'fy_start', 
      'maxlength':'11', 
      'size':'11', 
      'value':date_mysql_to_php($default_start,
    )
    $data['fy_end'] = 
      'name':'fy_end', 
      'id':'fy_end', 
      'maxlength':'11', 
      'size':'11', 
      'value':date_mysql_to_php($default_end,
    )
    
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
    $data['account_name']['value'] = @config.item('account_name')
    
    #  Form validations 
    @validation.set_rules('account_label', 'C/F Label', 'trim|required|min_length[2]|max_length[30]|alpha_numeric')
    @validation.set_rules('account_name', 'C/F Account Name', 'trim|required|min_length[2]|max_length[100]')
    @validation.set_rules('fy_start', 'C/F Financial Year Start', 'trim|required|is_date')
    @validation.set_rules('fy_end', 'C/F Financial Year End', 'trim|required|is_date')
    
    @validation.set_rules('database_name', 'Database Name', 'trim|required')
    @validation.set_rules('database_username', 'Database Username', 'trim|required')
    
    #  Repopulating form 
    if $_POST then 
      $data['account_label']['value'] = @input.post('account_label', true)
      $data['account_name']['value'] = @input.post('account_name', true)
      $data['fy_start']['value'] = @input.post('fy_start', true)
      $data['fy_end']['value'] = @input.post('fy_end', true)
      
      $data['create_database'] = @input.post('create_database', true)
      $data['database_name']['value'] = @input.post('database_name', true)
      $data['database_username']['value'] = @input.post('database_username', true)
      $data['database_password']['value'] = @input.post('database_password', true)
      $data['database_host']['value'] = @input.post('database_host', true)
      $data['database_port']['value'] = @input.post('database_port', true)
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'setting/cf', $data)
      return 
      
    else 
      $data_account_label = @input.post('account_label', true)
      $data_account_label = strtolower($data_account_label)
      $data_account_name = @input.post('account_name', true)
      $data_account_address = @config.item('account_address')
      $data_account_email = @config.item('account_email')
      $data_fy_start = date_php_to_mysql(@input.post('fy_start', true))
      $data_fy_end = date_php_to_mysql_end_time(@input.post('fy_end', true))
      $data_account_currency = @config.item('account_currency_symbol')
      $data_account_date = @config.item('account_date_format')
      $data_account_timezone = @config.item('account_timezone')
      
      $data_account_manage_inventory = $account_data.manage_inventory
      $data_account_account_locked = $account_data.account_locked
      
      $data_account_email_protocol = $account_data.email_protocol
      $data_account_email_host = $account_data.email_host
      $data_account_email_port = $account_data.email_port
      $data_account_email_username = $account_data.email_username
      $data_account_email_password = $account_data.email_password
      
      $data_account_print_paper_height = $account_data.print_paper_height
      $data_account_print_paper_width = $account_data.print_paper_width
      $data_account_print_margin_top = $account_data.print_margin_top
      $data_account_print_margin_bottom = $account_data.print_margin_bottom
      $data_account_print_margin_left = $account_data.print_margin_left
      $data_account_print_margin_right = $account_data.print_margin_right
      $data_account_print_orientation = $account_data.print_orientation
      $data_account_print_page_format = $account_data.print_page_format
      
      $data_database_type = 'mysql'
      $data_database_host = @input.post('database_host', true)
      $data_database_port = @input.post('database_port', true)
      $data_database_name = @input.post('database_name', true)
      $data_database_username = @input.post('database_username', true)
      $data_database_password = @input.post('database_password', true)
      
      $ini_file = @config.item('config_path') + "accounts/" + $data_account_label + ".ini"
      
      #  Check if database ini file exists 
      if get_file_info($ini_file) then 
        @messages.add('Account with same label already exists.', 'error')
        @template.load('template', 'setting/cf', $data)
        return 
        
      
      #  Check if start date is less than end date 
      if $data_fy_end<=$data_fy_start then 
        @messages.add('Financial start date cannot be greater than end date.', 'error')
        @template.load('template', 'setting/cf', $data)
        return 
        
      
      if $data_database_host is "" then $data_database_host = "localhost"if $data_database_port is "" then $data_database_port = "3306"if @input.post('create_database', true) is "1" then 
        $new_link = mysql_connect($data_database_host + ':' + $data_database_port, $data_database_username, $data_database_password)
        if $new_link then 
          #  Check if database already exists 
          $db_selected = mysql_select_db($data_database_name, $new_link)
          if $db_selected then 
            mysql_close($new_link)
            @messages.add('Database already exists.', 'error')
            @template.load('template', 'setting/cf', $data)
            return 
            
          
          #  Creating account database 
          $db_create_q = 'CREATE DATABASE ' + mysql_real_escape_string($data_database_name)
          if mysql_query($db_create_q, $new_link) then 
            @messages.add('Created account database.', 'success')
            else 
            @messages.add('Error creating account database. ' + mysql_error(), 'error')
            @template.load('template', 'setting/cf', $data)
            return 
            
          mysql_close($new_link)
          else 
          @messages.add('Error connecting to database. ' + mysql_error(), 'error')
          @template.load('template', 'setting/cf', $data)
          return 
          
        $dsn = "mysql://${data_database_username}:${data_database_password}@${data_database_host}:${data_database_port}/${data_database_name}"$newacc = @load.database($dsn, true)if not $newacc.conn_id then 
        @messages.add('Error connecting to database.', 'error')
        @template.load('template', 'setting/cf', $data)
        return 
        else if $newacc._error_message() isnt "" then 
        @messages.add('Error connecting to database. ' + $newacc._error_message(), 'error')
        @template.load('template', 'setting/cf', $data)
        return 
        else if $newacc.query("SHOW TABLES").num_rows() > 0 then 
        @messages.add('Selected database in not empty.', 'error')
        @template.load('template', 'setting/cf', $data)
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
            @template.load('template', 'setting/cf', $data)
            return 
            
          
        @messages.add('Initialized account database.', 'success')
        
        #  Adding account settings 
        $newacc.trans_start()
        if not $newacc.query("INSERT INTO settings (id, name, address, email, fy_start, fy_end, currency_symbol, date_format, timezone, manage_inventory, account_locked, email_protocol, email_host, email_port, email_username, email_password, print_paper_height, print_paper_width, print_margin_top, print_margin_bottom, print_margin_left, print_margin_right, print_orientation, print_page_format, database_version) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [1, $data_account_name, $data_account_address, $data_account_email, $data_fy_start, $data_fy_end, $data_account_currency, $data_account_date, $data_account_timezone, $data_account_manage_inventory, 0, $data_account_email_protocol, $data_account_email_host, $data_account_email_port, $data_account_email_username, $data_account_email_password, $data_account_print_paper_height, $data_account_print_paper_width, $data_account_print_margin_top, $data_account_print_margin_bottom, $data_account_print_margin_left, $data_account_print_margin_right, $data_account_print_orientation, $data_account_print_page_format, 4]) then 
          $newacc.trans_rollback()
          @messages.add('Error adding account settings.', 'error')
          @template.load('template', 'setting/cf', $data)
          return 
          else 
          $newacc.trans_complete()
          @messages.add('Added account settings.', 'success')
          
        
        # ************** Importing the C/F Values : START *************
        
        $cf_status = true
        #  Importing Groups 
        @db.from('groups').order_by('id', 'asc')
        $group_q = @db.get()
        for $row in $group_q.result()
          if not $newacc.query("INSERT INTO groups (id, parent_id, name, affects_gross) VALUES (?, ?, ?, ?)", [$row.id, $row.parent_id, $row.name, $row.affects_gross]) then 
            @messages.add('Failed to add Group account - ' + $row.name + '.', 'error')
            $cf_status = false
            
          
        
        #  Only importing Assets and Liability closing balance 
        $assets = new Accountlist()
        $assets.init(1)
        $liability = new Accountlist()
        $liability.init(2)
        $cf_ledgers = array_merge($assets.get_ledger_ids(), $liability.get_ledger_ids())
        
        #  Importing Ledgers 
        @db.from('ledgers').order_by('id', 'asc')
        $ledger_q = @db.get()
        for $row in $ledger_q.result()
          #  CF only Assets and Liability with Closing Balance 
          if in_array($row.id, $cf_ledgers) then 
            #  Calculating closing balance for previous year 
            $cl_balance = @Ledger_model.get_ledger_balance($row.id)
            if float_ops($cl_balance, 0, '<') then 
              $op_balance =  - $cl_balance
              $op_balance_dc = "C"
              else 
              $op_balance = $cl_balance
              $op_balance_dc = "D"
              
            if not $newacc.query("INSERT INTO ledgers (id, group_id, name, op_balance, op_balance_dc, type, reconciliation) VALUES (?, ?, ?, ?, ?, ?, ?)", [$row.id, $row.group_id, $row.name, $op_balance, $op_balance_dc, $row.type, $row.reconciliation]) then 
              @messages.add('Failed to add Ledger account - ' + $row.name + '.', 'error')
              $cf_status = false
              
            else 
            if not $newacc.query("INSERT INTO ledgers (id, group_id, name, op_balance, op_balance_dc, type, reconciliation) VALUES (?, ?, ?, ?, ?, ?, ?)", [$row.id, $row.group_id, $row.name, 0, "D", $row.type, $row.reconciliation]) then 
              @messages.add('Failed to add Ledger account - ' + $row.name + '.', 'error')
              $cf_status = false
              
            
          
        
        #  Importing Entry Types 
        @db.from('entry_types').order_by('id', 'asc')
        $entry_type_q = @db.get()
        for $row in $entry_type_q.result()
          if not $newacc.query("INSERT INTO entry_types (id, label, name, description, base_type, numbering, prefix, suffix, zero_padding, bank_cash_ledger_restriction) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [$row.id, $row.label, $row.name, $row.description, $row.base_type, $row.numbering, $row.prefix, $row.suffix, $row.zero_padding, $row.bank_cash_ledger_restriction]) then 
            @messages.add('Failed to add Entry type  - ' + $row.name + '.', 'error')
            $cf_status = false
            
          
        
        #  Importing Tags 
        @db.from('tags').order_by('id', 'asc')
        $tag_q = @db.get()
        for $row in $tag_q.result()
          if not $newacc.query("INSERT INTO tags (id, title, color, background) VALUES (?, ?, ?, ?)", [$row.id, $row.title, $row.color, $row.background]) then 
            @messages.add('Failed to add Tag - ' + $row.title + '.', 'error')
            $cf_status = false
            
          
        
        if $cf_status then @messages.add('Account carried forward.', 'success')
        else @messages.add('Error carrying forward to new account.', 'error')
        
        
        #  Adding account settings to file. Code copied from manage controller 
        $con_details = "[database]" + "\r\n" + "db_type = \"" + $data_database_type + "\"" + "\r\n" + "db_hostname = \"" + $data_database_host + "\"" + "\r\n" + "db_port = \"" + $data_database_port + "\"" + "\r\n" + "db_name = \"" + $data_database_name + "\"" + "\r\n" + "db_username = \"" + $data_database_username + "\"" + "\r\n" + "db_password = \"" + $data_database_password + "\"" + "\r\n"
        
        $con_details_html = '[database]' + '<br />db_type = "' + $data_database_type + '"<br />db_hostname = "' + $data_database_host + '"<br />db_port = "' + $data_database_port + '"<br />db_name = "' + $data_database_name + '"<br />db_username = "' + $data_database_username + '"<br />db_password = "' + $data_database_password + '"<br />'
        
        #  Writing the connection string to end of file - writing in 'a' append mode 
        if not write_file($ini_file, $con_details) then 
          @messages.add('Failed to add account settings file. Check if "' + $ini_file + '" file is writable.', 'error')
          @messages.add('You can manually create a text file "' + $ini_file + '" with the following content :<br /><br />' + $con_details_html, 'error')
          else 
          @messages.add('Added account settings file to list of active accounts.', 'success')
          
        
        redirect('setting')
        return 
        }return }}#  Creating account database #  Setting database #  End of file cf.php #  Location: ./system/application/controllers/setting/cf.php 
module.exports = Cf