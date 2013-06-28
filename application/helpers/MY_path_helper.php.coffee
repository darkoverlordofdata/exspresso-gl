#+--------------------------------------------------------------------+
#  MY_path_helper.coffee
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

if not function_exists('asset_url') then
  exports.asset_url = asset_url =  ->
    #  the helper function doesn't have access to $this, so we need to get a reference to the
    #  CodeIgniter instance.  We'll store that reference as $CI and use it instead of $this

    #  return the asset_url
    return base_url() + @config.item('asset_path')
    
  

#  End of file path_helper.php 
#  Location: ./system/application/helpers/path_helper.php 
