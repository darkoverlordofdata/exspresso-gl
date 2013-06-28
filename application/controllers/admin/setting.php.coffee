#+--------------------------------------------------------------------+
#  setting.coffee
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
class Setting extends Controller
  
  Setting :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'General Settings')
    
    #  Default settings 
    $data['row_count'] = 20
    $data['log'] = 1
    
    #  Loading settings from ini file 
    $ini_file = @config.item('config_path') + "settings/general.ini"
    
    #  Check if database ini file exists 
    if get_file_info($ini_file) then 
      #  Parsing database ini file 
      $cur_setting = parse_ini_file($ini_file)
      if $cur_setting then 
        $data['row_count'] = if $cur_setting['row_count']?  then $cur_setting['row_count'] else "20"
        $data['log'] = if $cur_setting['log']?  then $cur_setting['log'] else "1"
        
      
    
    #  Form fields 
    $data['row_count_options'] = 
      '10':10, 
      '20':20, 
      '50':50, 
      '100':100, 
      '200':200, 
      
    
    #  Form validations 
    @validation.set_rules('row_count', 'Row Count', 'trim|required|is_natural_no_zero')
    @validation.set_rules('log', 'Log Messages', 'trim')
    
    #  Repopulating form 
    if $_POST then 
      $data['row_count'] = @input.post('row_count', true)
      $data['log'] = @input.post('log', true)
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('admin_template', 'admin/setting', $data)
      return 
      
    else 
      $data_row_count = @input.post('row_count', true)
      $data_log = @input.post('log', true)
      
      if $data_row_count < 0 or $data_row_count > 200 then 
        @messages.add('Invalid number of rows.', 'error')
        @template.load('admin_template', 'admin/setting')
        return 
        
      
      if $data_log is 1 then $data_log = 1else #  Writing the connection string to end of file - writing in 'a' append mode #  End of file setting.php #  Location: ./system/application/controllers/admin/setting.php $data_log = 0$new_setting = "[general]" + "\r\n" + "row_count = \"" + $data_row_count + "\"" + "\r\n" + "log = \"" + $data_log + "\"" + "\r\n"$new_setting_html = '[general]<br />row_count = "' + $data_row_count + '"<br />' + "log = \"" + $data_log + "\"" + "<br />"if not write_file($ini_file, $new_setting) then 
        @messages.add('Failed to update settings file. Check if "' + $ini_file + '" file is writable.', 'error')
        @messages.add('You can manually create a text file "' + $ini_file + '" with the following content :<br /><br />' + $new_setting_html, 'error')
        @template.load('admin_template', 'admin/setting', $data)
        return 
        else 
        @messages.add('General settings updated.', 'success')
        redirect('admin/setting')
        return 
        }return }}
module.exports = Setting