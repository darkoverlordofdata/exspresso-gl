#+--------------------------------------------------------------------+
#  help.coffee
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
class Help extends Controller
  index :  ->
    @template.set('page_title', 'Help')
    @template.load('template', 'help/index')
    return 
    
  
module.exports = Help

#  End of file help.php 
#  Location: ./system/application/controllers/help.php 
