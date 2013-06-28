#+--------------------------------------------------------------------+
#  Template.coffee
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

<% if not defined('BASEPATH') then die ('No direct script access allowed')

class Template
  template_data: {}
  
  set : ($name, $value) ->
    @template_data[$name] = $value
    
  
  load : ($template = '', $view = '', $view_data = {}, $return = false) ->
    @CI = get_instance()
    @set('contents', @CI.load.view($view, $view_data, true))
    return @CI.load.view($template, @template_data, $return)
    
  
module.exports = Template

#  End of file Template.php 
#  Location: ./system/application/libraries/Template.php 