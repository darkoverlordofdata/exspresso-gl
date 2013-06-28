#+--------------------------------------------------------------------+
#  welcome.coffee
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
class Welcome extends Controller
  
  Welcome :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Administer Webzash')
    
    #  Check status report 
    @load.library('statuscheck')
    $statuscheck = new Statuscheck()
    $statuscheck.check_permissions()
    if count($statuscheck.error_messages) > 0 then 
      @messages.add('One or more problems were detected with your installation. Check the ' + anchor('admin/status', 'Status report', 'title':'Check Status report', 'class':'anchor-link-a') + ' for more information.', 'error')
      
    
    @template.load('admin_template', 'admin/welcome')
    return 
    
  
module.exports = Welcome

#  End of file welcome.php 
#  Location: ./system/application/controllers/admin/welcome.php 
