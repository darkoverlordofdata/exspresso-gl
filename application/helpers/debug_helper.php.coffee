#+--------------------------------------------------------------------+
#  debug_helper.coffee
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

#
# Outputs an array or variable
#
# @param    $var array, string, integer
# @return    string
#

exports.debug_var = debug_var = ($var = '') ->
  $return = _before()
  if is_array($var) then 
    $return+=print_r($var, true)
    
  else 
    $return+=$var
    
  $return+=_after()
  return $return
  

# ------------------------------------------------------------------------------

#
# _before
#
# @return    string
#
exports._before = _before =  ->
  $before = '<div style="padding:10px 20px 10px 20px; background-color:#fbe6f2; border:1px solid #d893a1; color: #000; font-size: 12px;>' + "\n"
  $before+='<h5 style="font-family:verdana,sans-serif; font-weight:bold; font-size:18px;">Debug Helper Output</h5>' + "\n"
  $before+='<pre>' + "\n"
  return $before
  

# ------------------------------------------------------------------------------

#
# _after
#
# @return    string
#

exports._after = _after =  ->
  $after = '</pre>' + "\n"
  $after+='</div>' + "\n"
  return $after
  

