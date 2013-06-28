#+--------------------------------------------------------------------+
#  backup.coffee
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
class Backup extends Controller
  
  Backup :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.dbutil()
    @load.helper('download')
    
    #  Check access 
    if not check_access('backup account') then 
      @messages.add('Permission denied.', 'error')
      redirect('setting')
      return 
      
    
    $backup_filename = "backup" + date("dmYHis") + ".gz"
    
    #  Backup your entire database and assign it to a variable 
    $backup_data = @dbutil.backup()
    
    #  Write the backup file to server 
    if not write_file(@config.item('backup_path') + $backup_filename, $backup_data) then 
      @messages.add('Error saving backup file to server.' + ' Check if "' + @config.item('backup_path') + '" folder is writable.', 'error')
      redirect('setting')
      return 
      
    
    #  Send the file to your desktop 
    force_download($backup_filename, $backup_data)
    @logger.write_message("success", "Downloaded account backup")
    redirect('setting')
    return 
    
  
module.exports = Backup

#  End of file backup.php 
#  Location: ./system/application/controllers/setting/backup.php 
