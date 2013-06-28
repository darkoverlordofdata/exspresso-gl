#+--------------------------------------------------------------------+
#  custom_helper.coffee
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

#
# Converts D/C to Dr / Cr
#
# Covnerts the D/C received from database to corresponding
# Dr/Cr value for display.
#
# @access	public
# @param	string	'd' or 'c' from database table
# @return	string
#
if not function_exists('convert_dc') then 
  exports.convert_dc = convert_dc = ($label) ->
    if $label is "D" then return "Dr"else if $label is "C" then return "Cr"else #
    # Converts amount to Dr or Cr Value
    #
    # Covnerts the amount to 0 or Dr or Cr value for display
    #
    # @access	public
    # @param	float	amount for display
    # @return	string
    #return "Error"}}if not function_exists('convert_amount_dc') then 
      exports.convert_amount_dc = convert_amount_dc = ($amount) ->
        if $amount is "D" then return "0"else if $amount < 0 then return "Cr " + convert_cur( - $amount)else #
        # Converts Opening balance amount to Dr or Cr Value
        #
        # Covnerts the Opening balance amount to 0 or Dr or Cr value for display
        #
        # @access	public
        # @param	amount
        # @param	debit or credit
        # @return	string
        #return "Dr " + convert_cur($amount)}}if not function_exists('convert_opening') then 
          exports.convert_opening = convert_opening = ($amount, $dc) ->
            if $amount is 0 then return "0"else if $dc is 'D' then return "Dr " + convert_cur($amount)else #
            # Return the value of variable is set
            #
            # Return the value of varaible is set else return empty string
            #
            # @access	public
            # @param	a varaible
            # @return	string value
            #return "Cr " + convert_cur($amount)}}if not function_exists('convert_cur') then 
              exports.convert_cur = convert_cur = ($amount) ->
                return number_format($amount, 2, '.', '')
                
              if not function_exists('print_value') then 
              exports.print_value = print_value = ($value = null, $default = "") ->
                if $value?  then return $valueelse #
                # Return Entry Type information
                #
                # @access	public
                # @param	int entry type id
                # @return	array
                ##
                # Return Entry Type Id from Entry Type Name
                #
                # @access	public
                # @param	string entry type name
                # @return	int entry type id
                ##
                # Converts Entry number to proper entry prefix formats
                #
                # @access	public
                # @param	int entry type id
                # @return	string
                #return $default}}if not function_exists('entry_type_info') then 
                  exports.entry_type_info = entry_type_info = ($entry_type_id) ->
                                      $entry_type_all = @config.item('account_entry_types')
                    
                    if $entry_type_all[$entry_type_id] then 
                      return 
                        'id':$entry_type_all[$entry_type_id], 
                        'label':$entry_type_all[$entry_type_id]['label'], 
                        'name':$entry_type_all[$entry_type_id]['name'], 
                        'numbering':$entry_type_all[$entry_type_id]['numbering'], 
                        'prefix':$entry_type_all[$entry_type_id]['prefix'], 
                        'suffix':$entry_type_all[$entry_type_id]['suffix'], 
                        'zero_padding':$entry_type_all[$entry_type_id]['zero_padding'], 
                        'bank_cash_ledger_restriction':$entry_type_all[$entry_type_id]['bank_cash_ledger_restriction'], 
                        
                      else 
                      return 
                        'id':$entry_type_all[$entry_type_id], 
                        'label':'', 
                        'name':'(Unkonwn)', 
                        'numbering':1, 
                        'prefix':'', 
                        'suffix':'', 
                        'zero_padding':0, 
                        'bank_cash_ledger_restriction':5, 
                        
                      
                    
                  if not function_exists('entry_type_name_to_id') then 
                  exports.entry_type_name_to_id = entry_type_name_to_id = ($entry_type_name) ->
                                      $entry_type_all = @config.item('account_entry_types')
                    for $id, $row of $entry_type_all
                      if $row['label'] is $entry_type_name then 
                        return $id
                        break
                        
                      
                    return false
                    
                  if not function_exists('full_entry_number') then 
                  exports.full_entry_number = full_entry_number = ($entry_type_id, $entry_number) ->
                                      $entry_type_all = @config.item('account_entry_types')
                    $return_html = ""
                    if not $entry_type_all[$entry_type_id] then 
                      $return_html = $entry_number
                      else 
                      $return_html = $entry_type_all[$entry_type_id]['prefix'] + str_pad($entry_number, $entry_type_all[$entry_type_id]['zero_padding'], '0', STR_PAD_LEFT) + $entry_type_all[$entry_type_id]['suffix']
                      
                    if $return_html then return $return_htmlelse #
                    # Floating Point Operations
                    #
                    # Multiply the float by 100, convert it to integer,
                    # Perform the integer operation and then divide the result
                    # by 100 and return the result
                    #
                    # @access	public
                    # @param	float	number 1
                    # @param	float	number 2
                    # @param	string	operation to be performed
                    # @return	float	result of the operation
                    #return " "}}if not function_exists('float_ops') then 
                      exports.float_ops = float_ops = ($param1 = 0, $param2 = 0, $op = '') ->
                        $result = 0
                        $param1 = $param1 * 100
                        $param2 = $param2 * 100
                        $param1 = round($param1, 0)
                        $param2 = round($param2, 0)
                        switch $op
                          when '+'
                            $result = $param1 + $param2
                            
                          when '-'
                            $result = $param1 - $param2
                            
                          when '=='
                            if $param1 is $param2 then :
                            if $param1 isnt $param2 then :
                            if $param1 < $param2 then :
                            if $param1 > $param2 then return trueelse return falsebreak}$result = $result / 100return $result}}#  End of file custom_helper.php #  Location: ./system/application/helpers/custom_helper.php 