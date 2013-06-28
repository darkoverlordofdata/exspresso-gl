#+--------------------------------------------------------------------+
#  email.coffee
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
class Email extends Controller
  
  Email :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Email Settings')
    $account_data = @Setting_model.get_current()
    
    #  Form fields 
    $data['email_protocol_options'] = 
      'mail':'mail', 
      'sendmail':'sendmail', 
      'smtp':'smtp'
      
    $data['email_host'] = 
      'name':'email_host', 
      'id':'email_host', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['email_port'] = 
      'name':'email_port', 
      'id':'email_port', 
      'maxlength':'5', 
      'size':'5', 
      'value':'', 
      
    $data['email_username'] = 
      'name':'email_username', 
      'id':'email_username', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['email_password'] = 
      'name':'email_password', 
      'id':'email_password', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    if $account_data then 
      $data['email_protocol'] = if ($account_data.email_protocol) then print_value($account_data.email_protocol) else 'smtp'
      $data['email_host']['value'] = if ($account_data.email_host) then print_value($account_data.email_host) else ''
      $data['email_port']['value'] = if ($account_data.email_port) then print_value($account_data.email_port) else ''
      $data['email_username']['value'] = if ($account_data.email_username) then print_value($account_data.email_username) else ''
      
    
    #  Form validations 
    @validation.set_rules('email_protocol', 'Email Protocol', 'trim|required|min_length[2]|max_length[10]')
    @validation.set_rules('email_host', 'Mail Server Hostname', 'trim|max_length[255]')
    @validation.set_rules('email_port', 'Mail Server Port', 'trim|is_natural')
    @validation.set_rules('email_username', 'Email Username', 'trim|max_length[255]')
    @validation.set_rules('email_password', 'Email Password', 'trim|max_length[255]')
    
    #  Repopulating form 
    if $_POST then 
      $data['email_protocol'] = @input.post('email_protocol', true)
      $data['email_host']['value'] = @input.post('email_host', true)
      $data['email_port']['value'] = @input.post('email_port', true)
      $data['email_username']['value'] = @input.post('email_username', true)
      $data['email_password']['value'] = @input.post('email_password', true)
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'setting/email', $data)
      return 
      
    else 
      $data_email_protocol = @input.post('email_protocol', true)
      $data_email_host = @input.post('email_host', true)
      $data_email_port = @input.post('email_port', true)
      $data_email_username = @input.post('email_username', true)
      $data_email_password = @input.post('email_password', true)
      
      #  if password is blank then use the current password 
      if $data_email_password is "" then $data_email_password = $account_data.email_password@db.trans_start()#  Update settings 
      $update_data = 
        'email_protocol':$data_email_protocol, 
        'email_host':$data_email_host, 
        'email_port':$data_email_port, 
        'email_username':$data_email_username, 
        'email_password':$data_email_password, 
        
      if not @db.where('id', 1).update('settings', $update_data) then 
        @db.trans_rollback()
        @messages.add('Error updating email settings.', 'error')
        @logger.write_message("error", "Error updating email settings")
        @template.load('template', 'setting/email', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Email settings updated.', 'success')
        @logger.write_message("success", "Updated email settings")
        redirect('setting')
        return 
        
      
    return 
    
  
module.exports = Email

#  End of file email.php 
#  Location: ./system/application/controllers/setting/email.php 
