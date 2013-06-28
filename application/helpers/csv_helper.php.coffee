#+--------------------------------------------------------------------+
#  csv_helper.coffee
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

#  ------------------------------------------------------------------------

#
# CSV Helpers
# Inspiration from PHP Cookbook by David Sklar and Adam Trachtenberg
#
# @author		Jérôme Jaglale
# @link		http://maestric.com/en/doc/php/codeigniter_csv
#

#  ------------------------------------------------------------------------

#
# Array to CSV
#
# download == "" -> return CSV string
# download == "toto.csv" -> download file toto.csv
#
if not function_exists('array_to_csv') then 
  exports.array_to_csv = array_to_csv = ($array, $download = "") ->
    if $download isnt "" then 
      header('Content-Type: application/csv')
      header('Content-Disposition: attachement; filename="' + $download + '"')
      
    
    ob_start()
    $f = fopen('php://output', 'w') or show_error("Can't open php://output")
    $n = 0
    for $line in $array
      $n++
      if not fputcsv($f, $line) then 
        show_error("Can't write line $n: $line")
        
      
    fclose($f) or show_error("Can't close php://output")
    $str = ob_get_contents()
    ob_end_clean()
    
    if $download is "" then 
      return $str
      
    else 
      echo $str
      
    
  

#  ------------------------------------------------------------------------

#
# Query to CSV
#
# download == "" -> return CSV string
# download == "toto.csv" -> download file toto.csv
#
if not function_exists('query_to_csv') then 
  exports.query_to_csv = query_to_csv = ($query, $headers = true, $download = "") ->
    if not is_object($query) or  not method_exists($query, 'list_fields') then 
      show_error('invalid query')
      
    
    $array = {}
    
    if $headers then 
      $line = {}
      for $name in $query.list_fields()
        $line.push $name
        
      $array.push $line
      
    
    for $row in $query.result_array()
      $line = {}
      for $item in $row
        $line.push $item
        
      $array.push $line
      
    
    echo array_to_csv($array, $download)
    
  

#  End of file csv_helper.php 
#  Location: ./system/helpers/csv_helper.php 