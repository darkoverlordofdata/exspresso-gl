#+--------------------------------------------------------------------+
#  ledger_model.coffee
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
class Ledger_model extends Model
  
  Ledger_model :  ->
    parent::Model()
    
  
  get_all_ledgers :  ->
    $options = {}
    $options[0] = "(Please Select)"
    @db.from('ledgers').order_by('name', 'asc')
    $ledger_q = @db.get()
    for $row in $ledger_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
  get_all_ledgers_bankcash :  ->
    $options = {}
    $options[0] = "(Please Select)"
    @db.from('ledgers').where('type', 1).order_by('name', 'asc')
    $ledger_q = @db.get()
    for $row in $ledger_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
  get_all_ledgers_nobankcash :  ->
    $options = {}
    $options[0] = "(Please Select)"
    @db.from('ledgers').where('type !=', 1).order_by('name', 'asc')
    $ledger_q = @db.get()
    for $row in $ledger_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
  get_all_ledgers_reconciliation :  ->
    $options = {}
    $options[0] = "(Please Select)"
    @db.from('ledgers').where('reconciliation', 1).order_by('name', 'asc')
    $ledger_q = @db.get()
    for $row in $ledger_q.result()
      $options[$row.id] = $row.name
      
    return $options
    
  
  get_name : ($ledger_id) ->
    @db.from('ledgers').where('id', $ledger_id).limit(1)
    $ledger_q = @db.get()
    if $ledger = $ledger_q.row()) then $ledger.name
    else return "(Error)"}get_entry_name : ($entry_id, $entry_type_id) ->
      #  Selecting whether to show debit side Ledger or credit side Ledger 
      $current_entry_type = entry_type_info($entry_type_id)
      $ledger_type = 'C'
      
      if $current_entry_type['bank_cash_ledger_restriction'] is 3 then $ledger_type = 'D'@db.select('ledgers.name as name')
      @db.from('entry_items').join('ledgers', 'entry_items.ledger_id = ledgers.id').where('entry_items.entry_id', $entry_id).where('entry_items.dc', $ledger_type)
      $ledger_q = @db.get()
      if not $ledger = $ledger_q.row()) then return "(Invalid)"}else 
        $ledger_multiple = if ($ledger_q.num_rows() > 1) then true else false
        $html = ''
        if $ledger_multiple then $html+=anchor('entry/view/' + $current_entry_type['label'] + "/" + $entry_id, "(" + $ledger.name + ")", 'title':'View ' + $current_entry_type['name'] + ' Entry', 'class':'anchor-link-a')
        else $html+=anchor('entry/view/' + $current_entry_type['label'] + "/" + $entry_id, $ledger.name, 'title':'View ' + $current_entry_type['name'] + ' Entry', 'class':'anchor-link-a')
        return $html
        return }get_opp_ledger_name : ($entry_id, $entry_type_label, $ledger_type, $output_type) ->
        $output = ''
        if $ledger_type is 'D' then $opp_ledger_type = 'C'else $opp_ledger_type = 'D'@db.from('entry_items').where('entry_id', $entry_id).where('dc', $opp_ledger_type)$opp_entry_name_q = @db.get()if $opp_entry_name_d = $opp_entry_name_q.row()) then $opp_ledger_name = @get_name($opp_entry_name_d.ledger_id)if $opp_entry_name_q.num_rows() > 1 then 
          if $output_type is 'html' then $output = anchor('entry/view/' + $entry_type_label + '/' + $entry_id, "(" + $opp_ledger_name + ")", 'title':'View ' + ' Entry', 'class':'anchor-link-a')else $output = "(" + $opp_ledger_name + ")"}else 
            if $output_type is 'html' then $output = anchor('entry/view/' + $entry_type_label + '/' + $entry_id, $opp_ledger_name, 'title':'View ' + ' Entry', 'class':'anchor-link-a')else $output = $opp_ledger_name}}return $output}get_ledger_balance : ($ledger_id) ->
              [$op_bal, $op_bal_type] = @get_op_balance($ledger_id)
              
              $dr_total = @get_dr_total($ledger_id)
              $cr_total = @get_cr_total($ledger_id)
              
              $total = float_ops($dr_total, $cr_total, '-')
              if $op_bal_type is "D" then $total = float_ops($total, $op_bal, '+')else $total = float_ops($total, $op_bal, '-')return $total}get_op_balance : ($ledger_id) ->
                @db.from('ledgers').where('id', $ledger_id).limit(1)
                $op_bal_q = @db.get()
                if $op_bal = $op_bal_q.row()) then [$op_bal.op_balance, $op_bal.op_balance_dc]
                else #  Return debit total as positive value return [0, "D"]}get_diff_op_balance :  ->
                  #  Calculating difference in Opening Balance 
                  $total_op = 0
                  @db.from('ledgers').order_by('id', 'asc')
                  $ledgers_q = @db.get()
                  for $row in $ledgers_q.result()
                    [$opbalance, $optype] = @get_op_balance($row.id)
                    if $optype is "D" then 
                      $total_op = float_ops($total_op, $opbalance, '+')
                      else 
                      $total_op = float_ops($total_op, $opbalance, '-')
                      
                    
                  return $total_op
                  get_dr_total : ($ledger_id) ->
                  @db.select_sum('amount', 'drtotal').from('entry_items').join('entries', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).where('entry_items.dc', 'D')
                  $dr_total_q = @db.get()
                  if $dr_total = $dr_total_q.row()) then $dr_total.drtotal
                  else #  Return credit total as positive value return 0}get_cr_total : ($ledger_id) ->
                    @db.select_sum('amount', 'crtotal').from('entry_items').join('entries', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).where('entry_items.dc', 'C')
                    $cr_total_q = @db.get()
                    if $cr_total = $cr_total_q.row()) then $cr_total.crtotal
                    else #  Delete reconciliation entries for a Ledger account return 0}delete_reconciliation : ($ledger_id) ->
                      $update_data = 
                        'reconciliation_date':null, 
                        
                      @db.where('ledger_id', $ledger_id).update('entry_items', $update_data)
                      return 
                      }
module.exports = Ledger_model