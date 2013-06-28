#+--------------------------------------------------------------------+
#  setting_model.coffee
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
class Setting_model extends Model
  
  Setting_model :  ->
    parent::Model()
    
  
  get_current :  ->
    @db.from('settings').where('id', 1)
    $account_q = @db.get()
    return $account_q.row()
    
  
module.exports = Setting_model
