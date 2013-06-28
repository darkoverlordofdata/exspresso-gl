#+--------------------------------------------------------------------+
#  welcome.coffee
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
class Welcome extends Controller
  
  Welcome :  ->
    parent::Controller()
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Settings')
    @template.load('template', 'setting/index')
    return 
    
  
module.exports = Welcome

#  End of file welcome.php 
#  Location: ./system/application/controllers/setting/welcome.php 
