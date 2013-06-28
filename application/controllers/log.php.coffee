#+--------------------------------------------------------------------+
#  log.coffee
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
class Log extends Controller
  index :  ->
    @load.helper('text')
    @template.set('page_title', 'Logs')
    @template.set('nav_links', 'log/clear':'Clear Log')
    @template.load('template', 'log/index')
    
    #  Check access 
    if not check_access('view log') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    return 
    
  
  clear :  ->
    #  Check access 
    if not check_access('clear log') then 
      @messages.add('Permission denied.', 'error')
      redirect('log')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('log')
      return 
      
    
    if @db.truncate('logs') then 
      @messages.add('Log cleared.', 'success')
      redirect('log')
      else 
      @messages.add('Error clearing Log.', 'error')
      redirect('log')
      
    return 
    
  
module.exports = Log

#  End of file log.php 
#  Location: ./system/application/controllers/log.php 
