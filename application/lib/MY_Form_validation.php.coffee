#+--------------------------------------------------------------------+
#  MY_Form_validation.coffee
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

class MY_Form_validation extends CI_Form_validation
  
  My_Form_validation :  ->
    parent::CI_Form_validation()
    parent::set_error_delimiters('<li>', '</li>')
    
  
  #
  # Unique
  #
  # @access	public
  # @param	string
  # @param	field
  # @return	bool
  #
  unique : ($str, $field) ->
    $CI = get_instance()
    [$table, $column] = explode('.', $field, 2)
    
    $CI.validation.set_message('unique', 'The %s that you requested is already in use.')
    $CI.db.from($table).where($column, $str)
    $dup_query = $CI.db.get()
    if $dup_query.num_rows() > 0 then return falseelse return true}uniqueentryno : ($str, $type) ->
      $CI = get_instance()
      
      $CI.validation.set_message('uniqueentryno', 'The %s that you requested is already in use.')
      
      $CI.db.from('entries').where('number', $str).where('entry_type', $type)
      $dup_query = $CI.db.get()
      if $dup_query.num_rows() > 0 then return falseelse return true}uniqueentrynowithid : ($str, $field) ->
        $CI = get_instance()
        
        [$type, $id] = explode('.', $field, 2)
        $CI.validation.set_message('uniqueentrynowithid', 'The %s that you requested is already in use.')
        
        $CI.db.from('entries').where('number', $str).where('entry_type', $type).where('id !=', $id)
        $dup_query = $CI.db.get()
        if $dup_query.num_rows() > 0 then return falseelse return true}uniquewithid : ($str, $field) ->
          $CI = get_instance()
          [$table, $column, $id] = explode('.', $field, 3)
          
          $CI.validation.set_message('uniquewithid', 'The %s that you requested is already in use.')
          
          $CI.db.from($table).where($column, $str).where('id !=', $id)
          $dup_query = $CI.db.get()
          if $dup_query.num_rows() > 0 then return falseelse return true}is_dc : ($str) ->
            $CI = get_instance()
            
            $CI.validation.set_message('is_dc', '%s can only be "Dr" or "Cr".')
            return if ($str is "D" or $str is "C") then true else false
            currency : ($str) ->
            $CI = get_instance()
            if preg_match('/^[\-]/', $str) then 
              $CI.validation.set_message('currency', '%s cannot be negative.')
              return false
              
            
            if preg_match('/^[0-9]*\.?[0-9]{0,2}$/', $str) then 
              return true
              else 
              $CI.validation.set_message('currency', '%s must be a valid amount. Maximum 2 decimal places is allowed.')
              return false
              
            is_date : ($str) ->
            $CI = get_instance()
            
            $CI.validation.set_message('is_date', 'The %s is a invalid date.')
            
            $current_date_format = $CI.config.item('account_date_format')
            [$d, $m, $y] = [0, 0, 0]
            switch $current_date_format
              when 'dd/mm/yyyy'
                [$d, $m, $y] = explode('/', $str)
                
              when 'mm/dd/yyyy'
                [$m, $d, $y] = explode('/', $str)
                
              when 'yyyy/mm/dd'
                [$y, $m, $d] = explode('/', $str)
                
              else
                $CI.messages.add('Invalid date format. Check your account settings.', 'error')
                return ""
                
            return if checkdate($m, $d, $y) then true else false
            is_date_within_range : ($str) ->
            $CI = get_instance()
            $cur_date = date_php_to_mysql($str)
            $start_date = $CI.config.item('account_fy_start')
            $end_date = $CI.config.item('account_fy_end')
            
            if $cur_date < $start_date then 
              $CI.validation.set_message('is_date_within_range', 'The %s is less than start of current financial year.')
              return false
              else if $cur_date > $end_date then 
              $CI.validation.set_message('is_date_within_range', 'The %s is more than end of current financial year.')
              return false
              else 
              return true
              
            is_date_within_range_reconcil : ($str) ->
            $CI = get_instance()
            $cur_date = date_php_to_mysql($str)
            $start_date = $CI.config.item('account_fy_start')
            $end_date_orig = $CI.config.item('account_fy_end')
            $end_date_ts = date_mysql_to_timestamp($end_date_orig)
            $end_date = date("Y-m-d H:i:s", $end_date_ts + (30 * 24 * 60 * 60))#  Adding one extra month for reconciliation 
            
            if $cur_date < $start_date then 
              $CI.validation.set_message('is_date_within_range_reconcil', 'The %s is less than start of current financial year.')
              return false
              else if $cur_date > $end_date then 
              $CI.validation.set_message('is_date_within_range_reconcil', 'The %s is more than end of current financial year plus one month.')
              return false
              else 
              return true
              
            is_hex : ($str) ->
            $CI = get_instance()
            
            $CI.validation.set_message('is_hex', 'The %s is a invalid value.')
            
            if preg_match('/^[0-9A-Fa-f]*$/', $str) then return trueelse return false}} %>
module.exports = MY_Form_validation