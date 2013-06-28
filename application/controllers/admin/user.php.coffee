#+--------------------------------------------------------------------+
#  user.coffee
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

<% 
class User extends Controller
  
  User :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.helper('file')
    @template.set('page_title', 'Manage users')
    @template.set('nav_links', 'admin/user/add':'Add user')
    
    #  Getting list of files in the config - users directory 
    $users_list = get_filenames(@config.item('config_path') + 'users')
    $data['users'] = {}
    if $users_list then 
      for $row in $users_list
        #  Only include file ending with .ini 
        if substr($row,  - 4) is ".ini" then 
          $ini_label = substr($row, 0,  - 4)
          $data['users'][$ini_label] = $ini_label
          
        
      
    
    @template.load('admin_template', 'admin/user/index', $data)
    return 
    
  
  add :  ->
    @template.set('page_title', 'Add user')
    
    #  Form fields 
    $data['user_name'] = 
      'name':'user_name', 
      'id':'user_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['user_password'] = 
      'name':'user_password', 
      'id':'user_password', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['user_email'] = 
      'name':'user_email', 
      'id':'user_email', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['user_roles'] = 
      "administrator":"administrator", 
      "manager":"manager", 
      "accountant":"accountant", 
      "dataentry":"dataentry", 
      "guest":"guest", 
      
    
    $data['active_user_role'] = "administrator"
    $data['user_status'] = true
    
    #  Accounts Form fields 
    $data['accounts_active'] = ['(All Accounts)']
    #  Getting list of files in the config - accounts directory 
    $accounts_list = get_filenames(@config.item('config_path') + 'accounts')
    $data['accounts'] = '(All Accounts)':'(All Accounts)'
    if $accounts_list then 
      for $row in $accounts_list
        #  Only include file ending with .ini 
        if substr($row,  - 4) is ".ini" then 
          $ini_label = substr($row, 0,  - 4)
          $data['accounts'][$ini_label] = $ini_label
          
        
      
    
    #  Repopulating form 
    if $_POST then 
      $data['user_name']['value'] = @input.post('user_name', true)
      $data['user_password']['value'] = @input.post('user_password', true)
      $data['user_email']['value'] = @input.post('user_email', true)
      $data['active_user_role'] = @input.post('user_role', true)
      $data['user_status'] = @input.post('user_status', true)
      $data['accounts_active'] = @input.post('accounts', true)
      
    
    #  Form validations 
    @validation.set_rules('user_name', 'Username', 'trim|required|min_length[2]|max_length[30]|alpha_numeric')
    @validation.set_rules('user_password', 'Password', 'trim|required')
    @validation.set_rules('user_email', 'Email', 'trim|required|valid_email')
    @validation.set_rules('user_role', 'Role', 'trim|required')
    @validation.set_rules('user_status', 'Active', 'trim')
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('admin_template', 'admin/user/add', $data)
      return 
      
    else 
      $data_user_name = @input.post('user_name', true)
      $data_user_password = @input.post('user_password', true)
      $data_user_email = @input.post('user_email', true)
      $data_user_role = @input.post('user_role', true)
      $data_user_status = @input.post('user_status', true)
      if $data_user_status is 1 then $data_user_status = 1else #  Forming account querry string #  Check if user ini file exists #  Writing the connection string to end of file - writing in 'a' append mode $data_user_status = 0$data_accounts = @input.post('accounts', true)$data_accounts_string = ''if not $data_accounts then 
        @messages.add('Please select account.', 'error')
        @template.load('admin_template', 'admin/user/add', $data)
        return 
        else 
        if in_array('(All Accounts)', $data_accounts) then 
          $data_accounts_string = '*'
          else 
          #  Filtering out bogus accounts 
          $data_accounts_valid = array_intersect($data['accounts'], $data_accounts)
          $data_accounts_string = implode(",", $data_accounts_valid)
          
        $ini_file = @config.item('config_path') + "users/" + $data_user_name + ".ini"if get_file_info($ini_file) then 
        @messages.add('Username already exists.', 'error')
        @template.load('admin_template', 'admin/user/add', $data)
        return 
        $user_details = "[user]" + "\r\n" + "username = \"" + $data_user_name + "\"" + "\r\n" + "password = \"" + $data_user_password + "\"" + "\r\n" + "email = \"" + $data_user_email + "\"" + "\r\n" + "role = \"" + $data_user_role + "\"" + "\r\n" + "status = \"" + $data_user_status + "\"" + "\r\n" + "accounts = \"" + $data_accounts_string + "\"" + "\r\n"$user_details_html = "[user]" + "<br />" + "username = \"" + $data_user_name + "\"" + "<br />" + "password = \"" + $data_user_password + "\"" + "<br />" + "email = \"" + $data_user_email + "\"" + "<br />" + "role = \"" + $data_user_role + "\"" + "<br />" + "status = \"" + $data_user_status + "\"" + "<br />" + "accounts = \"" + $data_accounts_string + "\"" + "<br />"if not write_file($ini_file, $user_details) then 
        @messages.add('Failed to add user. Check if "' + $ini_file + '" file is writable.', 'error')
        @messages.add('You can manually create a text file "' + $ini_file + '" with the following content :<br /><br />' + $user_details_html, 'error')
        @template.load('admin_template', 'admin/user/add', $data)
        return 
        else 
        @messages.add('Added user.', 'success')
        redirect('admin/user')
        return 
        }return }edit : ($user_name) ->
        @template.set('page_title', 'Edit user')
        
        $ini_file = @config.item('config_path') + "users/" + $user_name + ".ini"
        
        #  Form fields 
        $data['user_password'] = 
          'name':'user_password', 
          'id':'user_password', 
          'maxlength':'100', 
          'size':'40', 
          'value':'', 
          
        
        $data['user_email'] = 
          'name':'user_email', 
          'id':'user_email', 
          'maxlength':'100', 
          'size':'40', 
          'value':'', 
          
        
        $data['user_roles'] = 
          "administrator":"administrator", 
          "manager":"manager", 
          "accountant":"accountant", 
          "dataentry":"dataentry", 
          "guest":"guest", 
          
        
        $data['user_name'] = $user_name
        $data['active_user_role'] = ""
        $data['user_status'] = true
        
        #  Accounts Form fields 
        $data['accounts_active'] = ['(All Accounts)']
        #  Getting list of files in the config - accounts directory 
        $accounts_list = get_filenames(@config.item('config_path') + 'accounts')
        $data['accounts'] = '(All Accounts)':'(All Accounts)'
        if $accounts_list then 
          for $row in $accounts_list
            #  Only include file ending with .ini 
            if substr($row,  - 4) is ".ini" then 
              $ini_label = substr($row, 0,  - 4)
              $data['accounts'][$ini_label] = $ini_label
              
            
          
        
        #  Repopulating form 
        if $_POST then 
          $data['user_password']['value'] = @input.post('user_password', true)
          $data['user_email']['value'] = @input.post('user_email', true)
          $data['active_user_role'] = @input.post('user_role', true)
          $data['user_status'] = @input.post('user_status', true)
          $data['accounts_active'] = @input.post('accounts', true)
          else 
          #  Check if user ini file exists 
          if not get_file_info($ini_file) then 
            @messages.add('User file "' + $ini_file + '" does not exists.', 'error')
            redirect('admin/user')
            return 
            else 
            #  Parsing user ini file 
            $active_users = parse_ini_file($ini_file)
            if not $active_users then 
              @messages.add('Invalid user file.', 'error')
              else 
              #  Check if all needed variables are set in ini file 
              if $active_users['username']?  then $data['user_name'] = $user_nameelse @messages.add('Username missing from user file.', 'error')if $active_users['password']?  then $data['user_password']['value'] = $active_users['password']else @messages.add('Password missing from user file.', 'error')if $active_users['email']?  then $data['user_email']['value'] = $active_users['email']else @messages.add('Email missing from user file.', 'error')if $active_users['role']?  then $data['active_user_role'] = $active_users['role']else @messages.add('Role missing from user file.', 'error')if $active_users['status']?  then $data['user_status'] = $active_users['status']else @messages.add('Status missing from user file.', 'error')if $active_users['accounts']?  then 
                if $active_users['accounts'] is "*" then 
                  $data['accounts_active'] = ['(All Accounts)']
                  else 
                  $data['accounts_active'] = explode(",", $active_users['accounts'])
                  
                else 
                @messages.add('Accounts missing from user file.', 'error')
                }}}@validation.set_rules('user_password', 'Password', 'trim|required')#  Form validations @validation.set_rules('user_email', 'Email', 'trim|required|valid_email')@validation.set_rules('user_role', 'Role', 'trim|required')@validation.set_rules('user_status', 'Active', 'trim')if @validation.run() is false then
                @messages.add(validation_errors(), 'error')
                @template.load('admin_template', 'admin/user/edit', $data)
                return 
                else 
                $data_user_password = @input.post('user_password', true)
                $data_user_email = @input.post('user_email', true)
                $data_user_role = @input.post('user_role', true)
                $data_user_status = @input.post('user_status', true)
                if $data_user_status is 1 then $data_user_status = 1else #  Forming account querry string #  Writing the connection string to end of file - writing in 'a' append mode #  End of file user.php #  Location: ./system/application/controllers/admin/user.php $data_user_status = 0$data_accounts = @input.post('accounts', true)$data_accounts_string = ''if not $data_accounts then 
                  @messages.add('Please select account.', 'error')
                  @template.load('admin_template', 'admin/user/edit', $data)
                  return 
                  else 
                  if in_array('(All Accounts)', $data_accounts) then 
                    $data_accounts_string = '*'
                    else 
                    #  Filtering out bogus accounts 
                    $data_accounts_valid = array_intersect($data['accounts'], $data_accounts)
                    $data_accounts_string = implode(",", $data_accounts_valid)
                    
                  $ini_file = @config.item('config_path') + "users/" + $user_name + ".ini"$user_details = "[user]" + "\r\n" + "username = \"" + $user_name + "\"" + "\r\n" + "password = \"" + $data_user_password + "\"" + "\r\n" + "email = \"" + $data_user_email + "\"" + "\r\n" + "role = \"" + $data_user_role + "\"" + "\r\n" + "status = \"" + $data_user_status + "\"" + "\r\n" + "accounts = \"" + $data_accounts_string + "\"" + "\r\n"$user_details_html = "[user]" + "<br />" + "username = \"" + $user_name + "\"" + "<br />" + "password = \"" + $data_user_password + "\"" + "<br />" + "email = \"" + $data_user_email + "\"" + "<br />" + "role = \"" + $data_user_role + "\"" + "<br />" + "status = \"" + $data_user_status + "\"" + "<br />" + "accounts = \"" + $data_accounts_string + "\"" + "<br />"if not write_file($ini_file, $user_details) then 
                  @messages.add('Failed to edit user. Check if "' + $ini_file + '" file is writable.', 'error')
                  @messages.add('You can manually edit the text file "' + $ini_file + '" with the following content :<br /><br />' + $user_details_html, 'error')
                  @template.load('admin_template', 'admin/user/edit', $data)
                  return 
                  else 
                  @messages.add('Updated user.', 'success')
                  redirect('admin/user')
                  return 
                  }return }delete : ($user_name) ->
                  @template.set('page_title', 'Delete user')
                  
                  if @session.userdata('user_name') is $user_name then 
                    @messages.add('Cannot delete currently logged in user.', 'error')
                    redirect('admin/user')
                    return 
                    
                  $ini_file = @config.item('config_path') + "users/" + $user_name + ".ini"
                  @messages.add('Delete ' + $ini_file + ' file manually.', 'error')
                  redirect('admin/user')
                  return 
                  }#  Validating form 
module.exports = User