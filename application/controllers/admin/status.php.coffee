#+--------------------------------------------------------------------+
#  status.coffee
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

<% 
class Status extends Controller
  
  Status :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('administer') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @load.library('statuscheck')
    @template.set('page_title', 'Status report')
    $statuscheck = new Statuscheck()
    $statuscheck.check_permissions()
    $data['error_messages'] = $statuscheck.error_messages
    @template.load('admin_template', 'admin/status', $data)
    return 
    
  
module.exports = Status

#  End of file status.php 
#  Location: ./system/application/controllers/admin/status.php 
