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
  index :  ->
    @load.model('Ledger_model')
    @template.set('page_title', 'Chart Of Accounts')
    @template.set('nav_links', 'group/add':'Add Group', 'ledger/add':'Add Ledger')
    
    #  Calculating difference in Opening Balance 
    $total_op = @Ledger_model.get_diff_op_balance()
    if $total_op > 0 then 
      @messages.add('Difference in Opening Balance is Dr ' + convert_cur($total_op) + '.', 'error')
      else if $total_op < 0 then 
      @messages.add('Difference in Opening Balance is Cr ' + convert_cur( - $total_op) + '.', 'error')
      
    
    @template.load('template', 'account/index')
    return 
    
  
module.exports = Account

#  End of file account.php 
#  Location: ./system/application/controllers/account.php 
