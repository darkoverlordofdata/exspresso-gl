#+--------------------------------------------------------------------+
#  entrytypes.coffee
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

<% 
class EntryTypes extends Controller
  
  EntryTypes :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Entry Types')
    @template.set('nav_links', 'setting/entrytypes/add':'Add Entry Type')
    
    @db.from('entry_types').order_by('id', 'asc')
    $data['entry_type_data'] = @db.get()
    
    @template.load('template', 'setting/entrytypes/index', $data)
    return 
    
  
  add :  ->
    @template.set('page_title', 'Add Entry Type')
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('setting/entrytypes')
      return 
      
    
    #  Form fields 
    $data['entry_type_label'] = 
      'name':'entry_type_label', 
      'id':'entry_type_label', 
      'maxlength':'15', 
      'size':'15', 
      'value':'', 
      
    
    $data['entry_type_name'] = 
      'name':'entry_type_name', 
      'id':'entry_type_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    
    $data['entry_type_description'] = 
      'name':'entry_type_description', 
      'id':'entry_type_description', 
      'cols':'47', 
      'rows':'5', 
      'value':'', 
      
    
    $data['entry_type_prefix'] = 
      'name':'entry_type_prefix', 
      'id':'entry_type_prefix', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    
    $data['entry_type_suffix'] = 
      'name':'entry_type_suffix', 
      'id':'entry_type_suffix', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    
    $data['entry_type_zero_padding'] = 
      'name':'entry_type_zero_padding', 
      'id':'entry_type_zero_padding', 
      'maxlength':'2', 
      'size':'2', 
      'value':'', 
      
    
    $data['entry_type_base_types'] = '1':'Normal Entry'# , '2' => 'Stock Entry');
    $data['entry_type_numberings'] = '1':'Auto', '2':'Manual (required)', '3':'Manual (optional)'
    $data['bank_cash_ledger_restrictions'] = 
      '1':'Unrestricted', 
      '2':'Atleast one Bank or Cash account must be present on Debit side', 
      '3':'Atleast one Bank or Cash account must be present on Credit side', 
      '4':'Only Bank or Cash account can be present on both Debit and Credit side', 
      '5':'Only NON Bank or Cash account can be present on both Debit and Credit side', 
      
    
    $data['entry_type_base_type_active'] = '1'
    $data['entry_type_numbering_active'] = '1'
    $data['bank_cash_ledger_restriction_active'] = '1'
    
    #  Repopulating form 
    if $_POST then 
      $data['entry_type_label']['value'] = @input.post('entry_type_label', true)
      $data['entry_type_name']['value'] = @input.post('entry_type_name', true)
      $data['entry_type_description']['value'] = @input.post('entry_type_description', true)
      $data['entry_type_prefix']['value'] = @input.post('entry_type_prefix', true)
      $data['entry_type_suffix']['value'] = @input.post('entry_type_suffix', true)
      $data['entry_type_zero_padding']['value'] = @input.post('entry_type_zero_padding', true)
      
      $data['entry_type_base_type_active'] = @input.post('entry_type_base_type', true)
      $data['entry_type_numbering_active'] = @input.post('entry_type_numbering', true)
      $data['bank_cash_ledger_restriction_active'] = @input.post('bank_cash_ledger_restriction', true)
      
    
    #  Form validations 
    @validation.set_rules('entry_type_label', 'Label', 'trim|required|min_length[2]|max_length[15]|alpha|unique[entry_types.label]')
    @validation.set_rules('entry_type_name', 'Name', 'trim|required|min_length[2]|max_length[100]|unique[entry_types.name]')
    @validation.set_rules('entry_type_description', 'Description', 'trim')
    @validation.set_rules('entry_type_prefix', 'Prefix', 'trim|max_length[10]')
    @validation.set_rules('entry_type_suffix', 'Suffix', 'trim|max_length[10]')
    @validation.set_rules('entry_type_zero_padding', 'Zero Padding', 'trim|max_length[2]|is_natural')
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'setting/entrytypes/add', $data)
      return 
      
    else 
      $data_entry_type_label = strtolower(@input.post('entry_type_label', true))
      $data_entry_type_name = ucfirst(@input.post('entry_type_name', true))
      $data_entry_type_description = @input.post('entry_type_description', true)
      $data_entry_type_prefix = @input.post('entry_type_prefix', true)
      $data_entry_type_suffix = @input.post('entry_type_suffix', true)
      $data_entry_type_zero_padding = @input.post('entry_type_zero_padding', true)
      $data_entry_type_base_type = @input.post('entry_type_base_type', true)
      $data_entry_type_numbering = @input.post('entry_type_numbering', true)
      $data_bank_cash_ledger_restriction = @input.post('bank_cash_ledger_restriction', true)
      
      if ($data_entry_type_base_type < 1) or ($data_entry_type_base_type > 2) then $data_entry_type_base_type = 1if ($data_entry_type_numbering < 1) or ($data_entry_type_numbering > 3) then $data_entry_type_numbering = 1if ($data_bank_cash_ledger_restriction < 1) or ($data_bank_cash_ledger_restriction > 5) then $data_bank_cash_ledger_restriction = 1$last_id = 1@db.select_max('id', 'lastid').from('entry_types')#  Calculating Entry Type Id $last_id_q = @db.get()if $row = $last_id_q.row()) then $last_id = $row.lastid$last_id++}@db.trans_start()$insert_data = 
        'id':$last_id, 
        'label':$data_entry_type_label, 
        'name':$data_entry_type_name, 
        'description':$data_entry_type_description, 
        'base_type':$data_entry_type_base_type, 
        'numbering':$data_entry_type_numbering, 
        'prefix':$data_entry_type_prefix, 
        'suffix':$data_entry_type_suffix, 
        'zero_padding':$data_entry_type_zero_padding, 
        'bank_cash_ledger_restriction':$data_bank_cash_ledger_restriction, 
        if not @db.insert('entry_types', $insert_data) then 
        @db.trans_rollback()
        @messages.add('Error addding Entry Type - ' + $data_entry_type_name + '.', 'error')
        @logger.write_message("error", "Error adding Entry Type called " + $data_entry_type_name)
        @template.load('template', 'setting/entrytypes/add', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Added Entry Type - ' + $data_entry_type_name + '.', 'success')
        @logger.write_message("success", "Added Entry Type called " + $data_entry_type_name)
        redirect('setting/entrytypes')
        return 
        }return }edit : ($id) ->
        @template.set('page_title', 'Edit Entry Type')
        
        #  Check for account lock 
        if @config.item('account_locked') is 1 then 
          @messages.add('Account is locked.', 'error')
          redirect('setting/entrytypes')
          return 
          
        
        #  Checking for valid data 
        $id = @input.xss_clean($id)
        $id = $id
        if $id < 0 then 
          @messages.add('Invalid Entry Type.', 'error')
          redirect('setting/entrytypes')
          return 
          
        
        #  Loading current Entry Type 
        @db.from('entry_types').where('id', $id)
        $entry_type_data_q = @db.get()
        if $entry_type_data_q.num_rows() < 1 then 
          @messages.add('Invalid Entry Type.', 'error')
          redirect('setting/entrytypes')
          return 
          
        $entry_type_data = $entry_type_data_q.row()
        
        #  Form fields 
        $data['entry_type_label'] = 
          'name':'entry_type_label', 
          'id':'entry_type_label', 
          'maxlength':'15', 
          'size':'15', 
          'value':$entry_type_data.label, 
          
        
        $data['entry_type_name'] = 
          'name':'entry_type_name', 
          'id':'entry_type_name', 
          'maxlength':'100', 
          'size':'40', 
          'value':$entry_type_data.name, 
          
        
        $data['entry_type_description'] = 
          'name':'entry_type_description', 
          'id':'entry_type_description', 
          'cols':'47', 
          'rows':'5', 
          'value':$entry_type_data.description, 
          
        
        $data['entry_type_prefix'] = 
          'name':'entry_type_prefix', 
          'id':'entry_type_prefix', 
          'maxlength':'10', 
          'size':'10', 
          'value':$entry_type_data.prefix, 
          
        
        $data['entry_type_suffix'] = 
          'name':'entry_type_suffix', 
          'id':'entry_type_suffix', 
          'maxlength':'10', 
          'size':'10', 
          'value':$entry_type_data.suffix, 
          
        
        $data['entry_type_zero_padding'] = 
          'name':'entry_type_zero_padding', 
          'id':'entry_type_zero_padding', 
          'maxlength':'2', 
          'size':'2', 
          'value':$entry_type_data.zero_padding, 
          
        
        $data['entry_type_base_types'] = '1':'Normal Entry'# , '2' => 'Stock Entry');
        $data['entry_type_numberings'] = '1':'Auto', '2':'Manual (required)', '3':'Manual (optional)'
        $data['bank_cash_ledger_restrictions'] = 
          '1':'Unrestricted', 
          '2':'Atleast one Bank or Cash account must be present on Debit side', 
          '3':'Atleast one Bank or Cash account must be present on Credit side', 
          '4':'Only Bank or Cash account can be present on both Debit and Credit side', 
          '5':'Only NON Bank or Cash account can be present on both Debit and Credit side', 
          
        
        $data['entry_type_base_type_active'] = $entry_type_data.base_type
        $data['entry_type_numbering_active'] = $entry_type_data.numbering
        $data['bank_cash_ledger_restriction_active'] = $entry_type_data.bank_cash_ledger_restriction
        $data['entry_type_id'] = $id
        
        #  Repopulating form 
        if $_POST then 
          $data['entry_type_label']['value'] = @input.post('entry_type_label', true)
          $data['entry_type_name']['value'] = @input.post('entry_type_name', true)
          $data['entry_type_description']['value'] = @input.post('entry_type_description', true)
          $data['entry_type_prefix']['value'] = @input.post('entry_type_prefix', true)
          $data['entry_type_suffix']['value'] = @input.post('entry_type_suffix', true)
          $data['entry_type_zero_padding']['value'] = @input.post('entry_type_zero_padding', true)
          
          $data['entry_type_base_type_active'] = @input.post('entry_type_base_type', true)
          $data['entry_type_numbering_active'] = @input.post('entry_type_numbering', true)
          $data['bank_cash_ledger_restriction_active'] = @input.post('bank_cash_ledger_restriction', true)
          
        
        #  Form validations 
        @validation.set_rules('entry_type_label', 'Label', 'trim|required|min_length[2]|max_length[15]|alpha|uniquewithid[entry_types.label.' + $id + ']')
        @validation.set_rules('entry_type_name', 'Name', 'trim|required|min_length[2]|max_length[100]|uniquewithid[entry_types.name.' + $id + ']')
        @validation.set_rules('entry_type_description', 'Description', 'trim')
        @validation.set_rules('entry_type_prefix', 'Prefix', 'trim|max_length[10]')
        @validation.set_rules('entry_type_suffix', 'Suffix', 'trim|max_length[10]')
        @validation.set_rules('entry_type_zero_padding', 'Zero Padding', 'trim|max_length[2]|is_natural')
        
        #  Validating form 
        if @validation.run() is false then
          @messages.add(validation_errors(), 'error')
          @template.load('template', 'setting/entrytypes/edit', $data)
          return 
          
        else 
          $data_entry_type_id = $id
          $data_entry_type_label = strtolower(@input.post('entry_type_label', true))
          $data_entry_type_name = ucfirst(@input.post('entry_type_name', true))
          $data_entry_type_description = @input.post('entry_type_description', true)
          $data_entry_type_prefix = @input.post('entry_type_prefix', true)
          $data_entry_type_suffix = @input.post('entry_type_suffix', true)
          $data_entry_type_zero_padding = @input.post('entry_type_zero_padding', true)
          $data_entry_type_base_type = @input.post('entry_type_base_type', true)
          $data_entry_type_numbering = @input.post('entry_type_numbering', true)
          $data_bank_cash_ledger_restriction = @input.post('bank_cash_ledger_restriction', true)
          
          if ($data_entry_type_base_type < 1) or ($data_entry_type_base_type > 2) then $data_entry_type_base_type = 1if ($data_entry_type_numbering < 1) or ($data_entry_type_numbering > 3) then $data_entry_type_numbering = 1if ($data_bank_cash_ledger_restriction < 1) or ($data_bank_cash_ledger_restriction > 5) then $data_bank_cash_ledger_restriction = 1@db.trans_start()$update_data = 
            'label':$data_entry_type_label, 
            'name':$data_entry_type_name, 
            'description':$data_entry_type_description, 
            'base_type':$data_entry_type_base_type, 
            'numbering':$data_entry_type_numbering, 
            'prefix':$data_entry_type_prefix, 
            'suffix':$data_entry_type_suffix, 
            'zero_padding':$data_entry_type_zero_padding, 
            'bank_cash_ledger_restriction':$data_bank_cash_ledger_restriction, 
            if not @db.where('id', $data_entry_type_id).update('entry_types', $update_data) then 
            @db.trans_rollback()
            @messages.add('Error updating Entry Type - ' + $data_entry_type_name + '.', 'error')
            @logger.write_message("error", "Error updating Entry Type called " + $data_entry_type_name + " [id:" + $id + "]")
            @template.load('template', 'setting/entrytypes/edit', $data)
            return 
            else 
            @db.trans_complete()
            @messages.add('Updated Entry Type - ' + $data_entry_type_name + '.', 'success')
            @logger.write_message("success", "Updated Entry Type called " + $data_entry_type_name + " [id:" + $id + "]")
            redirect('setting/entrytypes')
            return 
            }return }delete : ($id) ->
            #  Check for account lock 
            if @config.item('account_locked') is 1 then 
              @messages.add('Account is locked.', 'error')
              redirect('setting/entrytypes')
              return 
              
            
            #  Checking for valid data 
            $id = @input.xss_clean($id)
            $id = $id
            if $id<=0 then 
              @messages.add('Invalid Entry Type.', 'error')
              redirect('setting/entrytypes')
              return 
              
            
            #  Loading current Entry Type 
            @db.from('entry_types').where('id', $id)
            $entry_type_data_q = @db.get()
            if $entry_type_data_q.num_rows() < 1 then 
              @messages.add('Invalid Entry Type.', 'error')
              redirect('setting/entrytypes')
              return 
              else 
              $entry_type_data = $entry_type_data_q.row()
              
            
            #  Check if an Entry present for the Entry Type 
            @db.from('entries').where('entry_type', $id)
            $entry_data_q = @db.get()
            if $entry_data_q.num_rows() > 0 then 
              @messages.add('Cannot delete Entry Type. There are still ' + $entry_data_q.num_rows() + ' Entries present.', 'error')
              redirect('setting/entrytypes')
              return 
              
            
            #  Deleting Entry Types 
            @db.trans_start()
            if not @db.delete('entry_types', 'id':$id) then 
              @db.trans_rollback()
              @messages.add('Error deleting Entry Type - ' + $entry_type_data.name + '.', 'error')
              @logger.write_message("error", "Error deleting Entry Type called " + $entry_type_data.name + " [id:" + $id + "]")
              redirect('setting/entrytypes')
              return 
              else 
              @db.trans_complete()
              @messages.add('Deleted Entry Type - ' + $entry_type_data.name + '.', 'success')
              @logger.write_message("success", "Deleted Entry Type called " + $entry_type_data.name + " [id:" + $id + "]")
              redirect('setting/entrytypes')
              return 
              
            return 
            }#  End of file entrytypes.php #  Location: ./system/application/controllers/setting/entrytypes.php 
module.exports = EntryTypes