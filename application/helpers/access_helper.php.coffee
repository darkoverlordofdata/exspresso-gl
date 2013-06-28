#+--------------------------------------------------------------------+
#  access_helper.coffee
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
# Check if the currently logger in user has the necessary permissions
# to permform the given action
#
# Valid permissions strings are given below :
#
# 'view entry'
# 'create entry'
# 'edit entry'
# 'delete entry'
# 'print entry'
# 'email entry'
# 'download entry'
# 'create ledger'
# 'edit ledger'
# 'delete ledger'
# 'create group'
# 'edit group'
# 'delete group'
# 'create tag'
# 'edit tag'
# 'delete tag'
# 'view reports'
# 'view log'
# 'clear log'
# 'change account settings'
# 'cf account'
# 'backup account'
# 'administer'
#

if not function_exists('check_access') then 
  exports.check_access = check_access = ($action_name) ->
      $user_role = @session.userdata('user_role')
    $permissions['manager'] = [
      'view entry', 
      'create entry', 
      'edit entry', 
      'delete entry', 
      'print entry', 
      'email entry', 
      'download entry', 
      'create ledger', 
      'edit ledger', 
      'delete ledger', 
      'create group', 
      'edit group', 
      'delete group', 
      'create tag', 
      'edit tag', 
      'delete tag', 
      'view reports', 
      'view log', 
      'clear log', 
      'change account settings', 
      'cf account', 
      'backup account', 
      ]
    $permissions['accountant'] = [
      'view entry', 
      'create entry', 
      'edit entry', 
      'delete entry', 
      'print entry', 
      'email entry', 
      'download entry', 
      'create ledger', 
      'edit ledger', 
      'delete ledger', 
      'create group', 
      'edit group', 
      'delete group', 
      'create tag', 
      'edit tag', 
      'delete tag', 
      'view reports', 
      'view log', 
      'clear log', 
      ]
    $permissions['dataentry'] = [
      'view entry', 
      'create entry', 
      'edit entry', 
      'delete entry', 
      'print entry', 
      'email entry', 
      'download entry', 
      'create ledger', 
      'edit ledger', 
      ]
    $permissions['guest'] = [
      'view entry', 
      'print entry', 
      'email entry', 
      'download entry', 
      ]
    
    if not $user_role?  then return falseif $user_role is "administrator" then return trueif not $permissions[$user_role]?  then return falseif in_array($action_name, $permissions[$user_role]) then return trueelse #  End of file access_helper.php #  Location: ./system/application/helpers/access_helper.php return false}}#  If user is administrator then always allow access 