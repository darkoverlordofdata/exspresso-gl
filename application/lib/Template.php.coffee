#+--------------------------------------------------------------------+
#  Template.coffee
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