#+--------------------------------------------------------------------+
#  MY_form_helper.coffee
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

<% if not defined('BASEPATH') then die ('No direct script access allowed')

if not function_exists('form_dropdown_dc') then 
  exports.form_dropdown_dc = form_dropdown_dc = ($name, $selected = null, $extra = '') ->
    $options = "D":"Dr", "C":"Cr"
    
    #  If no selected state was submitted we will attempt to set it automatically
    if not ($selected is "D" or $selected is "C") then 
      #  If the form name appears in the $_POST array we have a winner!
      if $_POST[$name]?  then 
        $selected = $_POST[$name]
        
      
    
    if $extra isnt '' then $extra = ' ' + $extra$form = '<select name="' + $name + '"' + $extra + ' class="dc-dropdown" >'for $key, $val of $options
      $key = ''+$key
      $sel = if ($key is $selected) then ' selected="selected"' else ''
      $form+='<option value="' + $key + '"' + $sel + '>' + ''+$val + "</option>\n"
      $form+='</select>'
    
    return $form
    
  

if not function_exists('form_input_date') then 
  exports.form_input_date = form_input_date = ($data = '', $value = '', $extra = '') ->
    $defaults = 'type':'text', 'name':(( not is_array($data) then $data else ''), 'value':$value)
    
    return "<input " + _parse_form_attributes($data, $defaults) + $extra + " class=\"datepicker\"/>"
    
  

if not function_exists('form_input_date_restrict') then 
  exports.form_input_date_restrict = form_input_date_restrict = ($data = '', $value = '', $extra = '') ->
    $defaults = 'type':'text', 'name':(( not is_array($data) then $data else ''), 'value':$value)
    
    return "<input " + _parse_form_attributes($data, $defaults) + $extra + " class=\"datepicker-restrict\"/>"
    
  

if not function_exists('form_input_ledger') then 
  exports.form_input_ledger = form_input_ledger = ($name, $selected = null, $extra = '', $type = 'all') ->
    $CI = get_instance()
    $CI.load.model('Ledger_model')
    
    if $type is 'bankcash' then $options = $CI.Ledger_model.get_all_ledgers_bankcash()else if $type is 'nobankcash' then $options = $CI.Ledger_model.get_all_ledgers_nobankcash()else if $type is 'reconciliation' then $options = $CI.Ledger_model.get_all_ledgers_reconciliation()else #  If no selected state was submitted we will attempt to set it automatically#  End of file MY_form_helper.php #  Location: ./system/application/helpers/MY_form_helper.php $options = $CI.Ledger_model.get_all_ledgers()if not ($selected) then 
      #  If the form name appears in the $_POST array we have a winner!
      if $_POST[$name]?  then 
        $selected = $_POST[$name]
        
      if $extra isnt '' then $extra = ' ' + $extra$form = '<select name="' + $name + '"' + $extra + ' class="ledger-dropdown">'for $key, $val of $options
      $key = ''+$key
      $sel = if ($key is $selected) then ' selected="selected"' else ''
      $form+='<option value="' + $key + '"' + $sel + '>' + ''+$val + "</option>\n"
      $form+='</select>'return $form}}