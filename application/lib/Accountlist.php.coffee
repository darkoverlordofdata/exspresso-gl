#+--------------------------------------------------------------------+
#  Accountlist.coffee
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

class Accountlist

  id: 0
  name: ""
  total: 0
  optype: ""
  opbalance: 0
  children_groups: {}
  children_ledgers: {}
  counter: 0
  @$temp_max = @$temp_max ? {} = 0
  @$max_depth = @$max_depth ? {} = 0
  @$csv_data = @$csv_data ? {} = {}
  @$csv_row = @$csv_row ? {} = 0
  
  Accountlist :  ->
    return 
    
  
  init : ($id) ->
    $CI = get_instance()
    if $id is 0 then 
      @id = 0
      @name = "None"
      @total = 0
      
      else 
      $CI.db.from('groups').where('id', $id).limit(1)
      $group_q = $CI.db.get()
      $group = $group_q.row()
      @id = $group.id
      @name = $group.name
      @total = 0
      
    @add_sub_ledgers()
    @add_sub_groups()
    
  
  add_sub_groups :  ->
    $CI = get_instance()
    $CI.db.from('groups').where('parent_id', @id)
    $child_group_q = $CI.db.get()
    $counter = 0
    for $row in $child_group_q.result()
      @children_groups[$counter] = new Accountlist()
      @children_groups[$counter].init($row.id)
      @total = float_ops(@total, @children_groups[$counter].total, '+')
      $counter++
      
    
  add_sub_ledgers :  ->
    $CI = get_instance()
    $CI.load.model('Ledger_model')
    $CI.db.from('ledgers').where('group_id', @id)
    $child_ledger_q = $CI.db.get()
    $counter = 0
    for $row in $child_ledger_q.result()
      @children_ledgers[$counter]['id'] = $row.id
      @children_ledgers[$counter]['name'] = $row.name
      @children_ledgers[$counter]['total'] = $CI.Ledger_model.get_ledger_balance($row.id)
      [@children_ledgers[$counter]['opbalance'], @children_ledgers[$counter]['optype']] = $CI.Ledger_model.get_op_balance($row.id)
      @total = float_ops(@total, @children_ledgers[$counter]['total'], '+')
      $counter++
      
    
  
  #  Display Account list in Balance sheet and Profit and Loss st 
  account_st_short : ($c = 0) ->
    @counter = $c
    if @id isnt 0 then 
      echo "<tr class=\"tr-group\">"
      echo "<td class=\"td-group\">"
      echo @print_space(@counter)
      echo "&nbsp;" + @name
      echo "</td>"
      echo "<td align=\"right\">" + convert_amount_dc(@total) + @print_space(@counter) + "</td>"
      echo "</tr>"
      
    for $id, $data of @children_groups
      @counter++
      $data.account_st_short(@counter)
      @counter--
      
    if count(@children_ledgers) > 0 then 
      @counter++
      for $id, $data of @children_ledgers
        echo "<tr class=\"tr-ledger\">"
        echo "<td class=\"td-ledger\">"
        echo @print_space(@counter)
        echo "&nbsp;" + anchor('report/ledgerst/' + $data['id'], $data['name'], 'title':$data['name'] + ' Ledger Statement', 'style':'color:#000000')
        echo "</td>"
        echo "<td align=\"right\">" + convert_amount_dc($data['total']) + @print_space(@counter) + "</td>"
        echo "</tr>"
        
      @counter--
      
    
  
  #  Display chart of accounts view 
  account_st_main : ($c = 0) ->
    @counter = $c
    if @id isnt 0 then 
      echo "<tr class=\"tr-group\">"
      echo "<td class=\"td-group\">"
      echo @print_space(@counter)
      if @id<=4 then echo "&nbsp;<strong>" + @name + "</strong>"
      else echo "&nbsp;" + @name
      echo "</td>"
      echo "<td>Group Account</td>"
      echo "<td>-</td>"
      echo "<td>-</td>"
      
      if @id<=4 then 
        echo "<td class=\"td-actions\"></tr>"
        else 
        echo "<td class=\"td-actions\">" + anchor('group/edit/' + @id, "Edit", 'title':'Edit Group', 'class':'red-link')
        echo " &nbsp;" + anchor('group/delete/' + @id, img('src':asset_url( + "images/icons/delete.png", 'border':'0', 'alt':'Delete group')), 'class':"confirmClick", 'title':"Delete Group") + "</td>"
        
      echo "</tr>"
      
    for $id, $data of @children_groups
      @counter++
      $data.account_st_main(@counter)
      @counter--
      
    if count(@children_ledgers) > 0 then 
      @counter++
      for $id, $data of @children_ledgers
        echo "<tr class=\"tr-ledger\">"
        echo "<td class=\"td-ledger\">"
        echo @print_space(@counter)
        echo "&nbsp;" + anchor('report/ledgerst/' + $data['id'], $data['name'], 'title':$data['name'] + ' Ledger Statement', 'style':'color:#000000')
        echo "</td>"
        echo "<td>Ledger Account</td>"
        echo "<td>" + convert_opening($data['opbalance'], $data['optype']) + "</td>"
        echo "<td>" + convert_amount_dc($data['total']) + "</td>"
        echo "<td class=\"td-actions\">" + anchor('ledger/edit/' + $data['id'], 'Edit', 'title':"Edit Ledger", 'class':'red-link')
        echo " &nbsp;" + anchor('ledger/delete/' + $data['id'], img('src':asset_url( + "images/icons/delete.png", 'border':'0', 'alt':'Delete Ledger')), 'class':"confirmClick", 'title':"Delete Ledger") + "</td>"
        echo "</tr>"
        
      @counter--
      
    
  
  print_space : ($count) ->
    $html = ""
    for ($i = 1$i<=$count$i++)
    {
    $html+="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
    }
    return $html
    
  
  #  Build a array of groups and ledgers 
  build_array :  ->
    $item = 
      'id':@id, 
      'name':@name, 
      'type':"G", 
      'total':@total, 
      'child_groups':{}, 
      'child_ledgers':{}, 
      'depth':self::$temp_max, 
      
    $local_counter = 0
    if count(@children_groups) > 0 then 
      self::$temp_max++
      if self::$temp_max > self::$max_depth then self::$max_depth = self::$temp_maxfor $id, $data of @children_groups
        $item['child_groups'][$local_counter] = $data.build_array()
        $local_counter++
        self::$temp_max--
      
    $local_counter = 0
    if count(@children_ledgers) > 0 then 
      self::$temp_max++
      for $id, $data of @children_ledgers
        $item['child_ledgers'][$local_counter] = 
          'id':$data['id'], 
          'name':$data['name'], 
          'type':"L", 
          'total':$data['total'], 
          'child_groups':{}, 
          'child_ledgers':{}, 
          'depth':self::$temp_max, 
          
        $local_counter++
        
      self::$temp_max--
      
    return $item
    
  
  #  Show array of groups and ledgers as created by build_array() method 
  show_array : ($data) ->
    echo "<tr>"
    echo "<td>"
    echo @print_space($data['depth'])
    echo $data['depth'] + "-"
    echo $data['id']
    echo $data['name']
    echo $data['type']
    echo $data['total']
    if $data['child_ledgers'] then 
      for $id, $ledger_data of $data['child_ledgers']
        @show_array($ledger_data)
        
      
    if $data['child_groups'] then 
      for $id, $group_data of $data['child_groups']
        @show_array($group_data)
        
      
    echo "</td>"
    echo "</tr>"
    
  
  to_csv : ($data) ->
    $counter = 0
    while $counter < $data['depth']
      self::$csv_data[self::$csv_row][$counter] = ""
      $counter++
      
    
    self::$csv_data[self::$csv_row][$counter] = $data['name']
    $counter++
    
    while $counter < self::$max_depth + 3
      self::$csv_data[self::$csv_row][$counter] = ""
      $counter++
      
    self::$csv_data[self::$csv_row][$counter] = $data['type']
    $counter++
    
    if $data['total'] is 0 then 
      self::$csv_data[self::$csv_row][$counter] = ""
      $counter++
      self::$csv_data[self::$csv_row][$counter] = ""
      else if $data['total'] < 0 then 
      self::$csv_data[self::$csv_row][$counter] = "Cr"
      $counter++
      self::$csv_data[self::$csv_row][$counter] =  - $data['total']
      else 
      self::$csv_data[self::$csv_row][$counter] = "Dr"
      $counter++
      self::$csv_data[self::$csv_row][$counter] = $data['total']
      
    
    if $data['child_ledgers'] then 
      for $id, $ledger_data of $data['child_ledgers']
        self::$csv_row++
        @to_csv($ledger_data)
        
      
    if $data['child_groups'] then 
      for $id, $group_data of $data['child_groups']
        self::$csv_row++
        @to_csv($group_data)
        
      
    
  
  exports.function = function ? {}get_csv()
  {
  return self::$csv_data
  }
  
  exports.function = function ? {}add_blank_csv()
  {
  self::$csv_row++
  self::$csv_data[self::$csv_row] = ["", ""]
  self::$csv_row++
  self::$csv_data[self::$csv_row] = ["", ""]
  return 
  }
  
  exports.function = function ? {}add_row_csv($row = [""])
  {
  self::$csv_row++
  self::$csv_data[self::$csv_row] = $row
  return 
  }
  
  exports.function = function ? {}reset_max_depth()
  {
  self::$max_depth = 0
  self::$temp_max = 0
  }
  
  #
  # Return a array of sub ledgers with the object
  # Used in CF ledgers of type Assets and Liabilities
  #
  get_ledger_ids :  ->
    $ledgers = {}
    if count(@children_ledgers) > 0 then 
      for $id, $data of @children_ledgers
        $ledgers.push $data['id']
        
      
    if count(@children_groups) > 0 then 
      for $id, $data of @children_groups
        for $row in $data.get_ledger_ids()$ledgers.push $row
        
      
    return $ledgers
    
  
module.exports = Accountlist

