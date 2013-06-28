#+--------------------------------------------------------------------+
#  user.coffee
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

module.exports = class User extends system.core.Controller

  indexAction :  ->
    @redirect('user/login')

  
  loginAction :  ->
    @template.set('page_title', 'Login')
    @load.library('general')
    
    #  If user already logged in redirect to profile page 
    return @redirect('user/profile') if @session.userdata('user_name')

    $data = {}
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
      
    
    #  Form validations 
    @validation.set_rules('user_name', 'User name', 'trim|required|min_length[1]|max_length[100]')
    @validation.set_rules('user_password', 'Password', 'trim|required|min_length[1]|max_length[100]')
    
    #  Re-populating form 
    if @input.post()
      $data['user_name'] = 'value': @input.post('user_name', true)
      $data['user_password'] = 'value': @input.post('user_password', true)
      
    
    if @validation.run() is false
      @messages.add(validation_errors(), 'error')
      @template.load('user_template', 'user/login', $data)
      return 
      
    else 
      $data_user_name = @input.post('user_name', true)
      $data_user_password = @input.post('user_password', true)
      
      #  Check user ini file 
      if $active_user isnt @general.check_user($data_user_name)
        @template.load('user_template', 'user/login', $data)
        return

      
      #  Check user status 
      if $active_user['status'] isnt 1 
        @messages.add('User disabled.', 'error')
        @template.load('user_template', 'user/login', $data)
        return 
        
      
      #  Password verify 
      if $active_user['password'] is $data_user_password 
        @messages.add('Logged in as ' + $data_user_name + '.', 'success')
        @session.set_userdata('user_name', $data_user_name)
        @session.set_userdata('user_role', $active_user['role'])
        @redirect('')
        return 
      else
        @session.unset_userdata('user_name')
        @session.unset_userdata('user_role')
        @session.unset_userdata('active_account')
        @messages.add('Authentication failed.', 'error')
        @template.load('user_template', 'user/login', $data)
        return 
        
      
    return 
    
  
  logoutAction :  ->
    @session.unset_userdata('user_name')
    @session.unset_userdata('user_role')
    @session.unset_userdata('active_account')
    @session.sess_destroy()
    @messages.add('Logged out.', 'success')
    @redirect('user/login')
    
  
  accountAction :  ->
    @template.set('page_title', 'Change Account')
    @load.library('general')
    
    #  Show manage accounts links if user has permission 
    if check_access('administer') 
      @template.set('nav_links', 'admin/create':'Create account', 'admin/manage':'Manage accounts')
      
    
    #  Check access 
    if not (@session.userdata('user_name')) 
      @messages.add('Permission denied.', 'error')
      @redirect('')
      return 
      
    
    #  Currently active account 
    $data['active_account'] = @session.userdata('active_account')
    
    #  Getting list of files in the config - accounts directory 
    $accounts_list = get_filenames(@config.item('config_path') + 'accounts')
    $data['accounts'] = {}
    if $accounts_list 
      for $row in $accounts_list
        #  Only include file ending with .ini 
        if $row.substr(-4) is ".ini"
          $ini_label = $row.substr(0, -4)
          $data['accounts'][$ini_label] = $ini_label
          
        
      
    
    #  Check user ini file 
    if not $active_user = @general.check_user(@session.userdata('user_name'))
      @redirect('user/profile')
      return

    #  Filter user access to accounts 
    if $active_user['accounts'] isnt '*' 
      $valid_accounts = $active_user['accounts'].split(",")
      $data['accounts'] = array_intersect($data['accounts'], $valid_accounts)
      
    
    #  Form validations 
    @validation.set_rules('account', 'Account', 'trim|required')
    
    #  Repopulating form 
    if @input.post()
      $data['active_account'] = @input.post('account', true)
      
    
    #  Validating form : only if label name is not set from URL 
    if @validation.run() is false
      @messages.add(validation_errors(), 'error')
      @template.load('user_template', 'user/account', $data)
      return 
    else
      $data_active_account = @input.post('account', true)
      
      #  Check for valid account 
      if not $data_active_account[$data['accounts']]?
        @messages.add('Invalid account selected.', 'error')
        @template.load('user_template', 'user/account', $data)
        return 
        
      
      if not @general.check_account($data_active_account) 
        @template.load('user_template', 'user/account', $data)
        return 
        
      
      #  Setting new account database details in session 
      @session.set_userdata('active_account', $data_active_account)
      @messages.add('Account changed.', 'success')
      redirect('')
      
    return 
    
  
  profileAction :  ->
    @template.set('page_title', 'User Profile')
    
    #  Check access 
    if not (@session.userdata('user_name')) 
      @messages.add('Permission denied.', 'error')
      @redirect('')
      return 
      
    
    @template.load('user_template', 'user/profile')
    return 
    
  

#  End of file user.coffee
#  Location: ./application/controllers/user.coffee
