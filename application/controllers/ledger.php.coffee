#+--------------------------------------------------------------------+
#  ledger.coffee
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
class Ledger extends Controller
  
  Ledger :  ->
    parent::Controller()
    @load.model('Ledger_model')
    @load.model('Group_model')
    return 
    
  
  index :  ->
    redirect('ledger/add')
    return 
    
  
  add :  ->
    @template.set('page_title', 'New Ledger')
    
    #  Check access 
    if not check_access('create ledger') then 
      @messages.add('Permission denied.', 'error')
      redirect('account')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('account')
      return 
      
    
    #  Form fields 
    $data['ledger_name'] = 
      'name':'ledger_name', 
      'id':'ledger_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['ledger_group_id'] = @Group_model.get_ledger_groups()
    $data['op_balance'] = 
      'name':'op_balance', 
      'id':'op_balance', 
      'maxlength':'15', 
      'size':'15', 
      'value':'', 
      
    $data['ledger_group_active'] = 0
    $data['op_balance_dc'] = "D"
    $data['ledger_type_cashbank'] = false
    $data['reconciliation'] = false
    
    #  Form validations 
    @validation.set_rules('ledger_name', 'Ledger name', 'trim|required|min_length[2]|max_length[100]|unique[ledgers.name]')
    @validation.set_rules('ledger_group_id', 'Parent group', 'trim|required|is_natural_no_zero')
    @validation.set_rules('op_balance', 'Opening balance', 'trim|currency')
    @validation.set_rules('op_balance_dc', 'Opening balance type', 'trim|required|is_dc')
    
    #  Re-populating form 
    if $_POST then 
      $data['ledger_name']['value'] = @input.post('ledger_name', true)
      $data['op_balance']['value'] = @input.post('op_balance', true)
      $data['ledger_group_active'] = @input.post('ledger_group_id', true)
      $data['op_balance_dc'] = @input.post('op_balance_dc', true)
      $data['ledger_type_cashbank'] = @input.post('ledger_type_cashbank', true)
      $data['reconciliation'] = @input.post('reconciliation', true)
      
    
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'ledger/add', $data)
      return 
      
    else 
      $data_name = @input.post('ledger_name', true)
      $data_group_id = @input.post('ledger_group_id', true)
      $data_op_balance = @input.post('op_balance', true)
      $data_op_balance_dc = @input.post('op_balance_dc', true)
      $data_ledger_type_cashbank_value = @input.post('ledger_type_cashbank', true)
      $data_reconciliation = @input.post('reconciliation', true)
      
      if $data_group_id < 5 then 
        @messages.add('Invalid Parent group.', 'error')
        @template.load('template', 'ledger/add', $data)
        return 
        
      
      #  Check if parent group id present 
      @db.select('id').from('groups').where('id', $data_group_id)
      if @db.get().num_rows() < 1 then 
        @messages.add('Invalid Parent group.', 'error')
        @template.load('template', 'ledger/add', $data)
        return 
        
      
      if not $data_op_balance then 
        $data_op_balance = "0.00"
        
      
      if $data_ledger_type_cashbank_value is "1" then 
        $data_ledger_type = 1
        else 
        $data_ledger_type = 0
        
      
      if $data_reconciliation is "1" then 
        $data_reconciliation = 1
        else 
        $data_reconciliation = 0
        
      
      @db.trans_start()
      $insert_data = 
        'name':$data_name, 
        'group_id':$data_group_id, 
        'op_balance':$data_op_balance, 
        'op_balance_dc':$data_op_balance_dc, 
        'type':$data_ledger_type, 
        'reconciliation':$data_reconciliation, 
        
      if not @db.insert('ledgers', $insert_data) then 
        @db.trans_rollback()
        @messages.add('Error addding Ledger account - ' + $data_name + '.', 'error')
        @logger.write_message("error", "Error adding Ledger account called " + $data_name)
        @template.load('template', 'group/add', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Added Ledger account - ' + $data_name + '.', 'success')
        @logger.write_message("success", "Added Ledger account called " + $data_name)
        redirect('account')
        return 
        
      
    return 
    
  
  edit : ($id) ->
    @template.set('page_title', 'Edit Ledger')
    
    #  Check access 
    if not check_access('edit ledger') then 
      @messages.add('Permission denied.', 'error')
      redirect('account')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('account')
      return 
      
    
    #  Checking for valid data 
    $id = @input.xss_clean($id)
    $id = $id
    if $id < 1 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('account')
      return 
      
    
    #  Loading current group 
    @db.from('ledgers').where('id', $id)
    $ledger_data_q = @db.get()
    if $ledger_data_q.num_rows() < 1 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('account')
      return 
      
    $ledger_data = $ledger_data_q.row()
    
    #  Form fields 
    $data['ledger_name'] = 
      'name':'ledger_name', 
      'id':'ledger_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':$ledger_data.name, 
      
    $data['ledger_group_id'] = @Group_model.get_ledger_groups()
    $data['op_balance'] = 
      'name':'op_balance', 
      'id':'op_balance', 
      'maxlength':'15', 
      'size':'15', 
      'value':$ledger_data.op_balance, 
      
    $data['ledger_group_active'] = $ledger_data.group_id
    $data['op_balance_dc'] = $ledger_data.op_balance_dc
    $data['ledger_id'] = $id
    if $ledger_data.type is 1 then $data['ledger_type_cashbank'] = trueelse #  Form validations $data['ledger_type_cashbank'] = false$data['reconciliation'] = $ledger_data.reconciliation@validation.set_rules('ledger_name', 'Ledger name', 'trim|required|min_length[2]|max_length[100]|uniquewithid[ledgers.name.' + $id + ']')@validation.set_rules('ledger_group_id', 'Parent group', 'trim|required|is_natural_no_zero')
    @validation.set_rules('op_balance', 'Opening balance', 'trim|currency')
    @validation.set_rules('op_balance_dc', 'Opening balance type', 'trim|required|is_dc')
    
    #  Re-populating form 
    if $_POST then 
      $data['ledger_name']['value'] = @input.post('ledger_name', true)
      $data['ledger_group_active'] = @input.post('ledger_group_id', true)
      $data['op_balance']['value'] = @input.post('op_balance', true)
      $data['op_balance_dc'] = @input.post('op_balance_dc', true)
      $data['ledger_type_cashbank'] = @input.post('ledger_type_cashbank', true)
      $data['reconciliation'] = @input.post('reconciliation', true)
      
    
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'ledger/edit', $data)
      return 
      
    else 
      $data_name = @input.post('ledger_name', true)
      $data_group_id = @input.post('ledger_group_id', true)
      $data_op_balance = @input.post('op_balance', true)
      $data_op_balance_dc = @input.post('op_balance_dc', true)
      $data_id = $id
      $data_ledger_type_cashbank_value = @input.post('ledger_type_cashbank', true)
      $data_reconciliation = @input.post('reconciliation', true)
      
      if $data_group_id < 5 then 
        @messages.add('Invalid Parent group.', 'error')
        @template.load('template', 'ledger/edit', $data)
        return 
        
      
      #  Check if parent group id present 
      @db.select('id').from('groups').where('id', $data_group_id)
      if @db.get().num_rows() < 1 then 
        @messages.add('Invalid Parent group.', 'error')
        @template.load('template', 'ledger/edit', $data)
        return 
        
      
      if not $data_op_balance then 
        $data_op_balance = "0.00"
        
      
      #  Check if bank_cash_ledger_restriction both entry present 
      if $data_ledger_type_cashbank_value isnt "1" then 
        $entry_type_all = @config.item('account_entry_types')
        for $entry_type_id, $row of $entry_type_all
          #  Check for Entry types where bank_cash_ledger_restriction is for all ledgers 
          if $row['bank_cash_ledger_restriction'] is 4 then 
            @db.from('entry_items').join('entries', 'entry_items.entry_id = entries.id').where('entries.entry_type', $entry_type_id).where('entry_items.ledger_id', $id)
            $all_ledger_bank_cash_count = @db.get().num_rows()
            if $all_ledger_bank_cash_count > 0 then 
              @messages.add('Cannot remove the Bank or Cash Account status of this Ledger account since it is still linked with ' + $all_ledger_bank_cash_count + ' ' + $row['name'] + ' entries.', 'error')
              @template.load('template', 'ledger/edit', $data)
              return 
              
            
          
        
      
      if $data_ledger_type_cashbank_value is "1" then 
        $data_ledger_type = 1
        else 
        $data_ledger_type = 0
        
      
      if $data_reconciliation is "1" then 
        $data_reconciliation = 1
        else 
        $data_reconciliation = 0
        
      
      @db.trans_start()
      $update_data = 
        'name':$data_name, 
        'group_id':$data_group_id, 
        'op_balance':$data_op_balance, 
        'op_balance_dc':$data_op_balance_dc, 
        'type':$data_ledger_type, 
        'reconciliation':$data_reconciliation, 
        
      if not @db.where('id', $data_id).update('ledgers', $update_data) then 
        @db.trans_rollback()
        @messages.add('Error updating Ledger account - ' + $data_name + '.', 'error')
        @logger.write_message("error", "Error updating Ledger account called " + $data_name + " [id:" + $data_id + "]")
        @template.load('template', 'ledger/edit', $data)
        return 
        else 
        #  Deleting reconciliation data if reconciliation disabled 
        if ($ledger_data.reconciliation is 1) and ($data_reconciliation is 0) then 
          @Ledger_model.delete_reconciliation($data_id)
          
        @db.trans_complete()
        @messages.add('Updated Ledger account - ' + $data_name + '.', 'success')
        @logger.write_message("success", "Updated Ledger account called " + $data_name + " [id:" + $data_id + "]")
        redirect('account')
        return 
        
      
    return 
    
  
  delete : ($id) ->
    #  Check access 
    if not check_access('delete ledger') then 
      @messages.add('Permission denied.', 'error')
      redirect('account')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('account')
      return 
      
    
    #  Checking for valid data 
    $id = @input.xss_clean($id)
    $id = $id
    if $id < 1 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('account')
      return 
      
    @db.from('entry_items').where('ledger_id', $id)
    if @db.get().num_rows() > 0 then 
      @messages.add('Cannot delete non-empty Ledger account.', 'error')
      redirect('account')
      return 
      
    
    #  Get the ledger details 
    @db.from('ledgers').where('id', $id)
    $ledger_q = @db.get()
    if $ledger_q.num_rows() < 1 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('account')
      return 
      else 
      $ledger_data = $ledger_q.row()
      
    
    #  Deleting ledger 
    @db.trans_start()
    if not @db.delete('ledgers', 'id':$id) then 
      @db.trans_rollback()
      @messages.add('Error deleting Ledger account - ' + $ledger_data.name + '.', 'error')
      @logger.write_message("error", "Error deleting Ledger account called " + $ledger_data.name + " [id:" + $id + "]")
      redirect('account')
      return 
      else 
      #  Deleting reconciliation data if present 
      @Ledger_model.delete_reconciliation($id)
      @db.trans_complete()
      @messages.add('Deleted Ledger account - ' + $ledger_data.name + '.', 'success')
      @logger.write_message("success", "Deleted Ledger account called " + $ledger_data.name + " [id:" + $id + "]")
      redirect('account')
      return 
      
    return 
    
  
  balance : ($ledger_id = 0) ->
    if $ledger_id > 0 then echo @Ledger_model.get_ledger_balance($ledger_id)
    else echo ""
    return 
    
  
module.exports = Ledger

#  End of file ledger.php 
#  Location: ./system/application/controllers/ledger.php 
