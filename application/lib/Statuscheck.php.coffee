#+--------------------------------------------------------------------+
#  Statuscheck.coffee
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

class Statuscheck
  error_messages: {}
  
  Statuscheck :  ->
    @error_messages = {}
    
  
  check_permissions :  ->

    #  Writable check 
    $check_path = @config.item('config_path') + "settings/"
    if not is_writable($check_path) then 
      @error_messages.push 'Application settings directory "' + $check_path + '" is not writable. You will not able to edit any application related settings.'
      
    
    $check_path = @config.item('config_path') + "accounts/"
    if not is_writable($check_path) then 
      @error_messages.push 'Account settings directory "' + $check_path + '" is not writable. You will not able to add or edit any account related settings.'
      
    
    $check_path = @config.item('config_path') + "users/"
    if not is_writable($check_path) then 
      @error_messages.push 'User directory "' + $check_path + '" is not writable. You will not able to add or edit any users.'
      
    
    $check_path = @config.item('backup_path')
    if not is_writable($check_path) then 
      @error_messages.push 'Backup directory "' + $check_path + '" is not writable. You will not able to save or download any backups.'
      
    
    #  Security checks 
    $check_path = @config.item('config_path')
    if substr(symbolic_permissions(fileperms($check_path)),  - 3, 1) is "r" then 
      @error_messages.push 'Security Risk ! The application config directory "' + $check_path + '" is world readable.'
      
    if substr(symbolic_permissions(fileperms($check_path)),  - 2, 1) is "W" then 
      @error_messages.push 'Security Risk ! The application config directory "' + $check_path + '" is world writeable.'
      
    
    $check_path = @config.item('config_path') + "accounts/"
    if substr(symbolic_permissions(fileperms($check_path)),  - 3, 1) is "r" then 
      @error_messages.push 'Security Risk ! The application accounts directory "' + $check_path + '" is world readable.'
      
    if substr(symbolic_permissions(fileperms($check_path)),  - 2, 1) is "W" then 
      @error_messages.push 'Security Risk ! The application accounts directory "' + $check_path + '" is world writeable.'
      
    
    $check_path = @config.item('config_path') + "users/"
    if substr(symbolic_permissions(fileperms($check_path)),  - 3, 1) is "r" then 
      @error_messages.push 'Security Risk ! The users directory "' + $check_path + '" is world readable.'
      
    if substr(symbolic_permissions(fileperms($check_path)),  - 2, 1) is "W" then 
      @error_messages.push 'Security Risk ! The users directory "' + $check_path + '" is world writeable.'
      
    
    $check_path = @config.item('config_path') + "settings/"
    if substr(symbolic_permissions(fileperms($check_path)),  - 3, 1) is "r" then 
      @error_messages.push 'Security Risk ! The application settings directory "' + $check_path + '" is world readable.'
      
    if substr(symbolic_permissions(fileperms($check_path)),  - 2, 1) is "W" then 
      @error_messages.push 'Security Risk ! The application settings directory "' + $check_path + '" is world writeable.'
      
    
    $check_path = @config.item('backup_path')
    if substr(symbolic_permissions(fileperms($check_path)),  - 3, 1) is "r" then 
      @error_messages.push 'Security Risk ! The application backup directory "' + $check_path + '" is world readable.'
      
    if substr(symbolic_permissions(fileperms($check_path)),  - 2, 1) is "W" then 
      @error_messages.push 'Security Risk ! The application backup directory "' + $check_path + '" is world writeable.'
      
    
  
module.exports = Statuscheck

#  End of file Statuscheck.php 
#  Location: ./system/application/libraries/Statuscheck.php 
