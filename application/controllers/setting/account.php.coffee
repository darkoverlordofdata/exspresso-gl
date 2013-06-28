#+--------------------------------------------------------------------+
#  account.coffee
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
class Account extends Controller
  
  Account :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Account Settings')
    $account_data = @Setting_model.get_current()
    
    $default_start = '01/04/'
    $default_end = '31/03/'
    if date('n') > 3 then 
      $default_start+=date('Y')
      $default_end+=date('Y') + 1
      else 
      $default_start+=date('Y') - 1
      $default_end+=date('Y')
      
    
    #  Form fields 
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
      
    
    $data['fy_start'] = ''
    $data['fy_end'] = ''
    
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
    $data['account_locked'] = false
    
    #  Current account settings 
    if $account_data then 
      $data['account_name']['value'] = print_value($account_data.name)
      $data['account_address']['value'] = print_value($account_data.address)
      $data['account_email']['value'] = print_value($account_data.email)
      $data['account_currency']['value'] = print_value($account_data.currency_symbol)
      $data['account_date'] = print_value($account_data.date_format)
      $data['account_timezone'] = print_value($account_data.timezone)
      $data['fy_start'] = date_mysql_to_php(print_value($account_data.fy_start))
      $data['fy_end'] = date_mysql_to_php(print_value($account_data.fy_end))
      $data['account_locked'] = print_value($account_data.account_locked)
      
    
    #  Form validations 
    @validation.set_rules('account_name', 'Account Name', 'trim|required|min_length[2]|max_length[100]')
    @validation.set_rules('account_address', 'Account Address', 'trim|max_length[255]')
    @validation.set_rules('account_email', 'Account Email', 'trim|valid_email')
    @validation.set_rules('account_currency', 'Currency', 'trim|max_length[10]')
    @validation.set_rules('account_date', 'Date', 'trim|max_length[10]')
    @validation.set_rules('account_timezone', 'Timezone', 'trim|max_length[6]')
    @validation.set_rules('account_locked', 'Account Locked', 'trim')
    
    #  Repopulating form 
    if $_POST then 
      $data['account_name']['value'] = @input.post('account_name', true)
      $data['account_address']['value'] = @input.post('account_address', true)
      $data['account_email']['value'] = @input.post('account_email', true)
      $data['account_currency']['value'] = @input.post('account_currency', true)
      $data['account_date'] = @input.post('account_date', true)
      $data['account_timezone'] = @input.post('account_timezone', true)
      $data['account_locked'] = @input.post('account_locked', true)
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'setting/account', $data)
      return 
      
    else 
      $data_account_name = @input.post('account_name', true)
      $data_account_address = @input.post('account_address', true)
      $data_account_email = @input.post('account_email', true)
      $data_account_currency = @input.post('account_currency', true)
      $data_account_date_form = @input.post('account_date', true)
      #  Checking for valid format 
      if $data_account_date_form is "dd/mm/yyyy" then $data_account_date = "dd/mm/yyyy"else if $data_account_date_form is "mm/dd/yyyy" then $data_account_date = "mm/dd/yyyy"else if $data_account_date_form is "yyyy/mm/dd" then $data_account_date = "yyyy/mm/dd"else #  End of file account.php #  Location: ./system/application/controllers/setting/account.php $data_account_date = "dd/mm/yyyy"$data_account_timezone = @input.post('timezones', true)$data_account_locked = @input.post('account_locked', true)if $data_account_locked isnt 1 then $data_account_locked = 0@db.trans_start()#  Update settings $update_data = 
        'name':$data_account_name, 
        'address':$data_account_address, 
        'email':$data_account_email, 
        'currency_symbol':$data_account_currency, 
        'date_format':$data_account_date, 
        'timezone':$data_account_timezone, 
        'account_locked':$data_account_locked, 
        if not @db.where('id', 1).update('settings', $update_data) then 
        @db.trans_rollback()
        @messages.add('Error updating account settings.', 'error')
        @logger.write_message("error", "Error updating account settings")
        @template.load('template', 'setting/account', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Account settings updated.', 'success')
        @logger.write_message("success", "Updated account settings")
        redirect('setting')
        return 
        }return }}
module.exports = Account