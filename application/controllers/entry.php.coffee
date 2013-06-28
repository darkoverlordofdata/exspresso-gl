#+--------------------------------------------------------------------+
#  entry.coffee
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
class Entry extends Controller
  
  Entry :  ->
    parent::Controller()
    @load.model('Entry_model')
    @load.model('Ledger_model')
    @load.model('Tag_model')
    return 
    
  
  index :  ->
    redirect('entry/show/all')
    return 
    
  
  show : ($entry_type) ->
    @load.model('Tag_model')
    
    $data['tag_id'] = 0
    $entry_type_id = 0
    
    if $entry_type is 'tag' then 
      $tag_id = @uri.segment(4)
      if $tag_id < 1 then 
        @messages.add('Invalid Tag.', 'error')
        redirect('entry/show/all')
        return 
        
      $data['tag_id'] = $tag_id
      $tag_name = @Tag_model.tag_name($tag_id)
      @template.set('page_title', 'Entries Tagged "' + $tag_name + '"')
      else if $entry_type is 'all' then 
      $entry_type_id = 0
      @template.set('page_title', 'All Entries')
      else 
      $entry_type_id = entry_type_name_to_id($entry_type)
      if not $entry_type_id then 
        @messages.add('Invalid Entry type specified. Showing all Entries.', 'error')
        redirect('entry/show/all')
        return 
        else 
        $current_entry_type = entry_type_info($entry_type_id)
        @template.set('page_title', $current_entry_type['name'] + ' Entries')
        @template.set('nav_links', 'entry/add/' + $current_entry_type['label']:'New ' + $current_entry_type['name'] + ' Entry')
        
      
    
    $entry_q = null
    
    #  Pagination setup 
    @load.library('pagination')
    
    if $entry_type is "tag" then $page_count = @uri.segment(5)else #  Show entry add actions #  Show entry edit actions $page_count = @uri.segment(4)$page_count = @input.xss_clean($page_count)if not $page_count then $page_count = "0"if $entry_type is 'tag' then 
      $config['base_url'] = site_url('entry/show/tag' + $tag_id)
      $config['uri_segment'] = 5
      else if $entry_type is 'all' then 
      $config['base_url'] = site_url('entry/show/all')
      $config['uri_segment'] = 4
      else 
      $config['base_url'] = site_url('entry/show/' + $current_entry_type['label'])
      $config['uri_segment'] = 4
      $pagination_counter = @config.item('row_count')$config['num_links'] = 10$config['per_page'] = $pagination_counter$config['full_tag_open'] = '<ul id="pagination-flickr">'$config['full_close_open'] = '</ul>'$config['num_tag_open'] = '<li>'$config['num_tag_close'] = '</li>'$config['cur_tag_open'] = '<li class="active">'$config['cur_tag_close'] = '</li>'$config['next_link'] = 'Next &#187;'$config['next_tag_open'] = '<li class="next">'$config['next_tag_close'] = '</li>'$config['prev_link'] = '&#171; Previous'$config['prev_tag_open'] = '<li class="previous">'$config['prev_tag_close'] = '</li>'$config['first_link'] = 'First'$config['first_tag_open'] = '<li class="first">'$config['first_tag_close'] = '</li>'$config['last_link'] = 'Last'$config['last_tag_open'] = '<li class="last">'$config['last_tag_close'] = '</li>'if $entry_type is "tag" then 
      @db.from('entries').where('tag_id', $tag_id).order_by('date', 'desc').order_by('number', 'desc').limit($pagination_counter, $page_count)
      $entry_q = @db.get()
      $config['total_rows'] = @db.from('entries').where('tag_id', $tag_id).get().num_rows()
      else if $entry_type_id > 0 then 
      @db.from('entries').where('entry_type', $entry_type_id).order_by('date', 'desc').order_by('number', 'desc').limit($pagination_counter, $page_count)
      $entry_q = @db.get()
      $config['total_rows'] = @db.from('entries').where('entry_type', $entry_type_id).get().num_rows()
      else 
      @db.from('entries').order_by('date', 'desc').order_by('number', 'desc').limit($pagination_counter, $page_count)
      $entry_q = @db.get()
      $config['total_rows'] = @db.count_all('entries')
      @pagination.initialize($config)#  Pagination configuration #  Pagination initializing if @session.userdata('entry_added_show_action') then 
      $entry_added_id_temp = @session.userdata('entry_added_id')
      $entry_added_type_id_temp = @session.userdata('entry_added_type_id')
      $entry_added_type_label_temp = @session.userdata('entry_added_type_label')
      $entry_added_type_name_temp = @session.userdata('entry_added_type_name')
      $entry_added_number_temp = @session.userdata('entry_added_number')
      $entry_added_message = 'Added ' + $entry_added_type_name_temp + ' Entry number ' + full_entry_number($entry_added_type_id_temp, $entry_added_number_temp) + "."
      $entry_added_message+=" You can [ "
      $entry_added_message+=anchor('entry/view/' + $entry_added_type_label_temp + "/" + $entry_added_id_temp, 'View', 'class':'anchor-link-a') + " | "
      $entry_added_message+=anchor('entry/edit/' + $entry_added_type_label_temp + "/" + $entry_added_id_temp, 'Edit', 'class':'anchor-link-a') + " | "
      $entry_added_message+=anchor_popup('entry/printpreview/' + $entry_added_type_label_temp + "/" + $entry_added_id_temp, 'Print', 'class':'anchor-link-a', 'width':'600', 'height':'600') + " | "
      $entry_added_message+=anchor_popup('entry/email/' + $entry_added_type_label_temp + "/" + $entry_added_id_temp, 'Email', 'class':'anchor-link-a', 'width':'500', 'height':'300') + " | "
      $entry_added_message+=anchor('entry/download/' + $entry_added_type_label_temp + "/" + $entry_added_id_temp, 'Download', 'class':'anchor-link-a')
      $entry_added_message+=" ] it."
      @messages.add($entry_added_message, 'success')
      @session.unset_userdata('entry_added_show_action')
      @session.unset_userdata('entry_added_id')
      @session.unset_userdata('entry_added_type_id')
      @session.unset_userdata('entry_added_type_label')
      @session.unset_userdata('entry_added_type_name')
      @session.unset_userdata('entry_added_number')
      if @session.userdata('entry_updated_show_action') then 
      $entry_updated_id_temp = @session.userdata('entry_updated_id')
      $entry_updated_type_id_temp = @session.userdata('entry_updated_type_id')
      $entry_updated_type_label_temp = @session.userdata('entry_updated_type_label')
      $entry_updated_type_name_temp = @session.userdata('entry_updated_type_name')
      $entry_updated_number_temp = @session.userdata('entry_updated_number')
      $entry_updated_message = 'Updated ' + $entry_updated_type_name_temp + ' Entry number ' + full_entry_number($entry_updated_type_id_temp, $entry_updated_number_temp) + "."
      $entry_updated_message+=" You can [ "
      $entry_updated_message+=anchor('entry/view/' + $entry_updated_type_label_temp + "/" + $entry_updated_id_temp, 'View', 'class':'anchor-link-a') + " | "
      $entry_updated_message+=anchor('entry/edit/' + $entry_updated_type_label_temp + "/" + $entry_updated_id_temp, 'Edit', 'class':'anchor-link-a') + " | "
      $entry_updated_message+=anchor_popup('entry/printpreview/' + $entry_updated_type_label_temp + "/" + $entry_updated_id_temp, 'Print', 'class':'anchor-link-a', 'width':'600', 'height':'600') + " | "
      $entry_updated_message+=anchor_popup('entry/email/' + $entry_updated_type_label_temp + "/" + $entry_updated_id_temp, 'Email', 'class':'anchor-link-a', 'width':'500', 'height':'300') + " | "
      $entry_updated_message+=anchor('entry/download/' + $entry_updated_type_label_temp + "/" + $entry_updated_id_temp, 'Download', 'class':'anchor-link-a')
      $entry_updated_message+=" ] it."
      @messages.add($entry_updated_message, 'success')
      
      if @session.userdata('entry_updated_has_reconciliation') then @messages.add('Previous reconciliations for this entry are no longer valid. You need to redo the reconciliations for this entry.', 'success')
      
      @session.unset_userdata('entry_updated_show_action')
      @session.unset_userdata('entry_updated_id')
      @session.unset_userdata('entry_updated_type_id')
      @session.unset_userdata('entry_updated_type_label')
      @session.unset_userdata('entry_updated_type_name')
      @session.unset_userdata('entry_updated_number')
      @session.unset_userdata('entry_updated_has_reconciliation')
      $data['entry_data'] = $entry_q@template.load('template', 'entry/index', $data)return }view : ($entry_type, $entry_id = 0) ->
      #  Entry Type 
      $entry_type_id = entry_type_name_to_id($entry_type)
      if not $entry_type_id then 
        @messages.add('Invalid Entry type.', 'error')
        redirect('entry/show/all')
        return 
        else 
        $current_entry_type = entry_type_info($entry_type_id)
        
      
      @template.set('page_title', 'View ' + $current_entry_type['name'] + ' Entry')
      
      #  Load current entry details 
      if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
      redirect('entry/show/' + $current_entry_type['label'])
      return 
      }
      #  Load current entry details 
      @db.from('entry_items').where('entry_id', $entry_id).order_by('id', 'asc')
      $cur_entry_ledgers = @db.get()
      if $cur_entry_ledgers.num_rows() < 1 then 
        @messages.add('Entry has no associated Ledger accounts.', 'error')
        
      $data['cur_entry'] = $cur_entry
      $data['cur_entry_ledgers'] = $cur_entry_ledgers
      $data['entry_type_id'] = $entry_type_id
      $data['current_entry_type'] = $current_entry_type
      @template.load('template', 'entry/view', $data)
      return 
      add : ($entry_type) ->
      #  Check access 
      if not check_access('create entry') then 
        @messages.add('Permission denied.', 'error')
        redirect('entry/show/' + $entry_type)
        return 
        
      
      #  Check for account lock 
      if @config.item('account_locked') is 1 then 
        @messages.add('Account is locked.', 'error')
        redirect('entry/show/' + $entry_type)
        return 
        
      
      #  Entry Type 
      $entry_type_id = entry_type_name_to_id($entry_type)
      if not $entry_type_id then 
        @messages.add('Invalid Entry type.', 'error')
        redirect('entry/show/all')
        return 
        else 
        $current_entry_type = entry_type_info($entry_type_id)
        
      
      @template.set('page_title', 'New ' + $current_entry_type['name'] + ' Entry')
      
      #  Form fields 
      $data['entry_number'] = 
        'name':'entry_number', 
        'id':'entry_number', 
        'maxlength':'11', 
        'size':'11', 
        'value':'', 
        
      $data['entry_date'] = 
        'name':'entry_date', 
        'id':'entry_date', 
        'maxlength':'11', 
        'size':'11', 
        'value':date_today_php(,
      )
      $data['entry_narration'] = 
        'name':'entry_narration', 
        'id':'entry_narration', 
        'cols':'50', 
        'rows':'4', 
        'value':'', 
        
      $data['entry_type_id'] = $entry_type_id
      $data['current_entry_type'] = $current_entry_type
      $data['entry_tags'] = @Tag_model.get_all_tags()
      $data['entry_tag'] = 0
      
      #  Form validations 
      if $current_entry_type['numbering'] is '2' then @validation.set_rules('entry_number', 'Entry Number', 'trim|required|is_natural_no_zero|uniqueentryno[' + $entry_type_id + ']')
      else if $current_entry_type['numbering'] is '3' then @validation.set_rules('entry_number', 'Entry Number', 'trim|is_natural_no_zero|uniqueentryno[' + $entry_type_id + ']')
      else @validation.set_rules('entry_number', 'Entry Number', 'trim|is_natural_no_zero|uniqueentryno[' + $entry_type_id + ']')
      @validation.set_rules('entry_date', 'Entry Date', 'trim|required|is_date|is_date_within_range')
      @validation.set_rules('entry_narration', 'trim')
      @validation.set_rules('entry_tag', 'Tag', 'trim|is_natural')
      
      #  Debit and Credit amount validation 
      if $_POST then 
        for $id, $ledger_data of @input.post('ledger_dc', true)
          @validation.set_rules('dr_amount[' + $id + ']', 'Debit Amount', 'trim|currency')
          @validation.set_rules('cr_amount[' + $id + ']', 'Credit Amount', 'trim|currency')
          
        
      
      #  Repopulating form 
      if $_POST then 
        $data['entry_number']['value'] = @input.post('entry_number', true)
        $data['entry_date']['value'] = @input.post('entry_date', true)
        $data['entry_narration']['value'] = @input.post('entry_narration', true)
        $data['entry_tag'] = @input.post('entry_tag', true)
        
        $data['ledger_dc'] = @input.post('ledger_dc', true)
        $data['ledger_id'] = @input.post('ledger_id', true)
        $data['dr_amount'] = @input.post('dr_amount', true)
        $data['cr_amount'] = @input.post('cr_amount', true)
        else 
        for ($count = 0$count<=3$count++)
        {
        if $count is 0 and $entry_type is "payment" then $data['ledger_dc'][$count] = "C"else if $count is 1 and $entry_type isnt "payment" then $data['ledger_dc'][$count] = "C"else #  End of file entry.php #  Location: ./system/application/controllers/entry.php $data['ledger_dc'][$count] = "D"$data['ledger_id'][$count] = 0$data['dr_amount'][$count] = ""$data['cr_amount'][$count] = ""}}if @validation.run() is false then
          @messages.add(validation_errors(), 'error')
          @template.load('template', 'entry/add', $data)
          return 
          else 
          #  Checking for Valid Ledgers account and Debit and Credit Total 
          $data_all_ledger_id = @input.post('ledger_id', true)
          $data_all_ledger_dc = @input.post('ledger_dc', true)
          $data_all_dr_amount = @input.post('dr_amount', true)
          $data_all_cr_amount = @input.post('cr_amount', true)
          $dr_total = 0
          $cr_total = 0
          $bank_cash_present = false#  Whether atleast one Ledger account is Bank or Cash account 
          $non_bank_cash_present = false#  Whether atleast one Ledger account is NOT a Bank or Cash account 
          for $id, $ledger_data of $data_all_ledger_dc
            if $data_all_ledger_id[$id] < 1 then continue
            
            #  Check for valid ledger id 
            @db.from('ledgers').where('id', $data_all_ledger_id[$id])
            $valid_ledger_q = @db.get()
            if $valid_ledger_q.num_rows() < 1 then 
              @messages.add('Invalid Ledger account.', 'error')
              @template.load('template', 'entry/add', $data)
              return 
              else 
              #  Check for valid ledger type 
              $valid_ledger = $valid_ledger_q.row()
              if $current_entry_type['bank_cash_ledger_restriction'] is '2' then 
                if $data_all_ledger_dc[$id] is 'D' and $valid_ledger.type is 1 then 
                  $bank_cash_present = true
                  
                if $valid_ledger.type isnt 1 then $non_bank_cash_present = true}else if $current_entry_type['bank_cash_ledger_restriction'] is '3' then 
                  if $data_all_ledger_dc[$id] is 'C' and $valid_ledger.type is 1 then 
                    $bank_cash_present = true
                    
                  if $valid_ledger.type isnt 1 then $non_bank_cash_present = true}else if $current_entry_type['bank_cash_ledger_restriction'] is '4' then 
                    if $valid_ledger.type isnt 1 then 
                      @messages.add('Invalid Ledger account. ' + $current_entry_type['name'] + ' Entries can have only Bank and Cash Ledgers accounts.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    else if $current_entry_type['bank_cash_ledger_restriction'] is '5' then 
                    if $valid_ledger.type is 1 then 
                      @messages.add('Invalid Ledger account. ' + $current_entry_type['name'] + ' Entries cannot have Bank and Cash Ledgers accounts.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    }if $data_all_ledger_dc[$id] is "D" then 
                    $dr_total = float_ops($data_all_dr_amount[$id], $dr_total, '+')
                    else 
                    $cr_total = float_ops($data_all_cr_amount[$id], $cr_total, '+')
                    }if float_ops($dr_total, $cr_total, '!=') then 
                    @messages.add('Debit and Credit Total does not match!', 'error')
                    @template.load('template', 'entry/add', $data)
                    return 
                    else if float_ops($dr_total, 0, '==') and float_ops($cr_total, 0, '==') then 
                    @messages.add('Cannot save empty Entry.', 'error')
                    @template.load('template', 'entry/add', $data)
                    return 
                    if $current_entry_type['bank_cash_ledger_restriction'] is '2' then 
                    if not $bank_cash_present then 
                      @messages.add('Need to Debit atleast one Bank or Cash account.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    if not $non_bank_cash_present then 
                      @messages.add('Need to Debit or Credit atleast one NON - Bank or Cash account.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    else if $current_entry_type['bank_cash_ledger_restriction'] is '3' then 
                    if not $bank_cash_present then 
                      @messages.add('Need to Credit atleast one Bank or Cash account.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    if not $non_bank_cash_present then 
                      @messages.add('Need to Debit or Credit atleast one NON - Bank or Cash account.', 'error')
                      @template.load('template', 'entry/add', $data)
                      return 
                      
                    if $current_entry_type['numbering'] is '2' then 
                    $data_number = @input.post('entry_number', true)
                    else if $current_entry_type['numbering'] is '3' then 
                    $data_number = @input.post('entry_number', true)
                    if not $data_number then $data_number = null}else 
                      if @input.post('entry_number', true) then $data_number = @input.post('entry_number', true)else #  Adding ledger accounts #  Updating Debit and Credit Total in entries table #  Success $data_number = @Entry_model.next_entry_number($entry_type_id)}$data_date = @input.post('entry_date', true)$data_narration = @input.post('entry_narration', true)$data_tag = @input.post('entry_tag', true)if $data_tag < 1 then $data_tag = null$data_type = $entry_type_id$data_date = date_php_to_mysql($data_date)$entry_id = null@db.trans_start()#  Converting date to MySQL$insert_data = 
                        'number':$data_number, 
                        'date':$data_date, 
                        'narration':$data_narration, 
                        'entry_type':$data_type, 
                        'tag_id':$data_tag, 
                        if not @db.insert('entries', $insert_data) then 
                        @db.trans_rollback()
                        @messages.add('Error addding Entry.', 'error')
                        @logger.write_message("error", "Error adding " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " since failed inserting entry")
                        @template.load('template', 'entry/add', $data)
                        return 
                        else 
                        $entry_id = @db.insert_id()
                        $data_all_ledger_dc = @input.post('ledger_dc', true)$data_all_ledger_id = @input.post('ledger_id', true)$data_all_dr_amount = @input.post('dr_amount', true)$data_all_cr_amount = @input.post('cr_amount', true)$dr_total = 0$cr_total = 0for $id, $ledger_data of $data_all_ledger_dc
                        $data_ledger_dc = $data_all_ledger_dc[$id]
                        $data_ledger_id = $data_all_ledger_id[$id]
                        if $data_ledger_id < 1 then continue
                        $data_amount = 0
                        if $data_all_ledger_dc[$id] is "D" then 
                          $data_amount = $data_all_dr_amount[$id]
                          $dr_total = float_ops($data_all_dr_amount[$id], $dr_total, '+')
                          else 
                          $data_amount = $data_all_cr_amount[$id]
                          $cr_total = float_ops($data_all_cr_amount[$id], $cr_total, '+')
                          
                        $insert_ledger_data = 
                          'entry_id':$entry_id, 
                          'ledger_id':$data_ledger_id, 
                          'amount':$data_amount, 
                          'dc':$data_ledger_dc, 
                          
                        if not @db.insert('entry_items', $insert_ledger_data) then 
                          @db.trans_rollback()
                          @messages.add('Error adding Ledger account - ' + $data_ledger_id + ' to Entry.', 'error')
                          @logger.write_message("error", "Error adding " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " since failed inserting entry ledger item " + "[id:" + $data_ledger_id + "]")
                          @template.load('template', 'entry/add', $data)
                          return 
                          
                        $update_data = 
                        'dr_total':$dr_total, 
                        'cr_total':$cr_total, 
                        if not @db.where('id', $entry_id).update('entries', $update_data) then 
                        @db.trans_rollback()
                        @messages.add('Error updating Entry total.', 'error')
                        @logger.write_message("error", "Error adding " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " since failed updating debit and credit total")
                        @template.load('template', 'entry/add', $data)
                        return 
                        @db.trans_complete()@session.set_userdata('entry_added_show_action', true)@session.set_userdata('entry_added_id', $entry_id)@session.set_userdata('entry_added_type_id', $entry_type_id)#  Check if atleast one Bank or Cash Ledger account is present #  Adding main entry @session.set_userdata('entry_added_type_label', $current_entry_type['label'])session.set_userdata('entry_added_type_name', $current_entry_type['name'])
          @session.set_userdata('entry_added_number', $data_number)
          
          #  Showing success message in show() method since message is too long for storing it in session 
          @logger.write_message("success", "Added " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
          redirect('entry/show/' + $current_entry_type['label'])
          @template.load('template', 'entry/add', $data)
          return 
          return }edit : ($entry_type, $entry_id = 0) ->
          #  Check access 
          if not check_access('edit entry') then 
            @messages.add('Permission denied.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Check for account lock 
          if @config.item('account_locked') is 1 then 
            @messages.add('Account is locked.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Entry Type 
          $entry_type_id = entry_type_name_to_id($entry_type)
          if not $entry_type_id then 
            @messages.add('Invalid Entry type.', 'error')
            redirect('entry/show/all')
            return 
            else 
            $current_entry_type = entry_type_info($entry_type_id)
            
          
          @template.set('page_title', 'Edit ' + $current_entry_type['name'] + ' Entry')
          
          #  Load current entry details 
          if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          }
          
          #  Form fields - Entry 
          $data['entry_number'] = 
            'name':'entry_number', 
            'id':'entry_number', 
            'maxlength':'11', 
            'size':'11', 
            'value':$cur_entry.number, 
            
          $data['entry_date'] = 
            'name':'entry_date', 
            'id':'entry_date', 
            'maxlength':'11', 
            'size':'11', 
            'value':date_mysql_to_php($cur_entry.date,
          )
          $data['entry_narration'] = 
            'name':'entry_narration', 
            'id':'entry_narration', 
            'cols':'50', 
            'rows':'4', 
            'value':$cur_entry.narration, 
            
          $data['entry_id'] = $entry_id
          $data['entry_type_id'] = $entry_type_id
          $data['current_entry_type'] = $current_entry_type
          $data['entry_tag'] = $cur_entry.tag_id
          $data['entry_tags'] = @Tag_model.get_all_tags()
          $data['has_reconciliation'] = false
          
          #  Load current ledger details if not $_POST 
          if not $_POST then 
            @db.from('entry_items').where('entry_id', $entry_id)
            $cur_ledgers_q = @db.get()
            if $cur_ledgers_q.num_rows<=0 then 
              @messages.add('No Ledger accounts found!', 'error')
              
            $counter = 0
            for $row in $cur_ledgers_q.result()
              $data['ledger_dc'][$counter] = $row.dc
              $data['ledger_id'][$counter] = $row.ledger_id
              if $row.dc is "D" then 
                $data['dr_amount'][$counter] = $row.amount
                $data['cr_amount'][$counter] = ""
                else 
                $data['dr_amount'][$counter] = ""
                $data['cr_amount'][$counter] = $row.amount
                
              if $row.reconciliation_date then $data['has_reconciliation'] = true$counter++
              
            #  Two extra rows 
            $data['ledger_dc'][$counter] = 'D'
            $data['ledger_id'][$counter] = 0
            $data['dr_amount'][$counter] = ""
            $data['cr_amount'][$counter] = ""
            $counter++
            $data['ledger_dc'][$counter] = 'D'
            $data['ledger_id'][$counter] = 0
            $data['dr_amount'][$counter] = ""
            $data['cr_amount'][$counter] = ""
            $counter++
            
          
          #  Form validations 
          if $current_entry_type['numbering'] is '3' then @validation.set_rules('entry_number', 'Entry Number', 'trim|is_natural_no_zero|uniqueentrynowithid[' + $entry_type_id + '.' + $entry_id + ']')
          else @validation.set_rules('entry_number', 'Entry Number', 'trim|required|is_natural_no_zero|uniqueentrynowithid[' + $entry_type_id + '.' + $entry_id + ']')
          @validation.set_rules('entry_date', 'Entry Date', 'trim|required|is_date|is_date_within_range')
          @validation.set_rules('entry_narration', 'trim')
          @validation.set_rules('entry_tag', 'Tag', 'trim|is_natural')
          
          #  Debit and Credit amount validation 
          if $_POST then 
            for $id, $ledger_data of @input.post('ledger_dc', true)
              @validation.set_rules('dr_amount[' + $id + ']', 'Debit Amount', 'trim|currency')
              @validation.set_rules('cr_amount[' + $id + ']', 'Credit Amount', 'trim|currency')
              
            
          
          #  Repopulating form 
          if $_POST then 
            $data['entry_number']['value'] = @input.post('entry_number', true)
            $data['entry_date']['value'] = @input.post('entry_date', true)
            $data['entry_narration']['value'] = @input.post('entry_narration', true)
            $data['entry_tag'] = @input.post('entry_tag', true)
            $data['has_reconciliation'] = @input.post('has_reconciliation', true)
            
            $data['ledger_dc'] = @input.post('ledger_dc', true)
            $data['ledger_id'] = @input.post('ledger_id', true)
            $data['dr_amount'] = @input.post('dr_amount', true)
            $data['cr_amount'] = @input.post('cr_amount', true)
            
          
          if @validation.run() is false then
            @messages.add(validation_errors(), 'error')
            @template.load('template', 'entry/edit', $data)
            else 
            #  Checking for Valid Ledgers account and Debit and Credit Total 
            $data_all_ledger_id = @input.post('ledger_id', true)
            $data_all_ledger_dc = @input.post('ledger_dc', true)
            $data_all_dr_amount = @input.post('dr_amount', true)
            $data_all_cr_amount = @input.post('cr_amount', true)
            $dr_total = 0
            $cr_total = 0
            $bank_cash_present = false#  Whether atleast one Ledger account is Bank or Cash account 
            $non_bank_cash_present = false#  Whether atleast one Ledger account is NOT a Bank or Cash account 
            for $id, $ledger_data of $data_all_ledger_dc
              if $data_all_ledger_id[$id] < 1 then continue
              
              #  Check for valid ledger id 
              @db.from('ledgers').where('id', $data_all_ledger_id[$id])
              $valid_ledger_q = @db.get()
              if $valid_ledger_q.num_rows() < 1 then 
                @messages.add('Invalid Ledger account.', 'error')
                @template.load('template', 'entry/edit', $data)
                return 
                else 
                #  Check for valid ledger type 
                $valid_ledger = $valid_ledger_q.row()
                if $current_entry_type['bank_cash_ledger_restriction'] is '2' then 
                  if $data_all_ledger_dc[$id] is 'D' and $valid_ledger.type is 1 then 
                    $bank_cash_present = true
                    
                  if $valid_ledger.type isnt 1 then $non_bank_cash_present = true}else if $current_entry_type['bank_cash_ledger_restriction'] is '3' then 
                    if $data_all_ledger_dc[$id] is 'C' and $valid_ledger.type is 1 then 
                      $bank_cash_present = true
                      
                    if $valid_ledger.type isnt 1 then $non_bank_cash_present = true}else if $current_entry_type['bank_cash_ledger_restriction'] is '4' then 
                      if $valid_ledger.type isnt 1 then 
                        @messages.add('Invalid Ledger account. ' + $current_entry_type['name'] + ' Entries can have only Bank and Cash Ledgers accounts.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      else if $current_entry_type['bank_cash_ledger_restriction'] is '5' then 
                      if $valid_ledger.type is 1 then 
                        @messages.add('Invalid Ledger account. ' + $current_entry_type['name'] + ' Entries cannot have Bank and Cash Ledgers accounts.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      }if $data_all_ledger_dc[$id] is "D" then 
                      $dr_total = float_ops($data_all_dr_amount[$id], $dr_total, '+')
                      else 
                      $cr_total = float_ops($data_all_cr_amount[$id], $cr_total, '+')
                      }if float_ops($dr_total, $cr_total, '!=') then 
                      @messages.add('Debit and Credit Total does not match!', 'error')
                      @template.load('template', 'entry/edit', $data)
                      return 
                      else if float_ops($dr_total, 0, '==') or float_ops($cr_total, 0, '==') then 
                      @messages.add('Cannot save empty Entry.', 'error')
                      @template.load('template', 'entry/edit', $data)
                      return 
                      if $current_entry_type['bank_cash_ledger_restriction'] is '2' then 
                      if not $bank_cash_present then 
                        @messages.add('Need to Debit atleast one Bank or Cash account.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      if not $non_bank_cash_present then 
                        @messages.add('Need to Debit or Credit atleast one NON - Bank or Cash account.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      else if $current_entry_type['bank_cash_ledger_restriction'] is '3' then 
                      if not $bank_cash_present then 
                        @messages.add('Need to Credit atleast one Bank or Cash account.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      if not $non_bank_cash_present then 
                        @messages.add('Need to Debit or Credit atleast one NON - Bank or Cash account.', 'error')
                        @template.load('template', 'entry/edit', $data)
                        return 
                        
                      if $current_entry_type['numbering'] is '3' then 
                      $data_number = @input.post('entry_number', true)
                      if not $data_number then $data_number = null}else 
                        $data_number = @input.post('entry_number', true)
                        $data_date = @input.post('entry_date', true)$data_narration = @input.post('entry_narration', true)$data_tag = @input.post('entry_tag', true)if $data_tag < 1 then $data_tag = null$data_type = $entry_type_id$data_date = date_php_to_mysql($data_date)$data_has_reconciliation = @input.post('has_reconciliation', true)@db.trans_start()#  Converting date to MySQL$update_data = 
                        'number':$data_number, 
                        'date':$data_date, 
                        'narration':$data_narration, 
                        'tag_id':$data_tag, 
                        if not @db.where('id', $entry_id).update('entries', $update_data) then 
                        @db.trans_rollback()
                        @messages.add('Error updating Entry account.', 'error')
                        @logger.write_message("error", "Error updating entry details for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
                        @template.load('template', 'entry/edit', $data)
                        return 
                        if not @db.delete('entry_items', 'entry_id':$entry_id) then 
                        @db.trans_rollback()
                        @messages.add('Error deleting previous Ledger accounts from Entry.', 'error')
                        @logger.write_message("error", "Error deleting previous entry items for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
                        @template.load('template', 'entry/edit', $data)
                        return 
                        $data_all_ledger_dc = @input.post('ledger_dc', true)$data_all_ledger_id = @input.post('ledger_id', true)$data_all_dr_amount = @input.post('dr_amount', true)$data_all_cr_amount = @input.post('cr_amount', true)$dr_total = 0$cr_total = 0for $id, $ledger_data of $data_all_ledger_dc
                        $data_ledger_dc = $data_all_ledger_dc[$id]
                        $data_ledger_id = $data_all_ledger_id[$id]
                        if $data_ledger_id < 1 then continue
                        $data_amount = 0
                        if $data_all_ledger_dc[$id] is "D" then 
                          $data_amount = $data_all_dr_amount[$id]
                          $dr_total = float_ops($data_all_dr_amount[$id], $dr_total, '+')
                          else 
                          $data_amount = $data_all_cr_amount[$id]
                          $cr_total = float_ops($data_all_cr_amount[$id], $cr_total, '+')
                          
                        
                        $insert_ledger_data = 
                          'entry_id':$entry_id, 
                          'ledger_id':$data_ledger_id, 
                          'amount':$data_amount, 
                          'dc':$data_ledger_dc, 
                          
                        if not @db.insert('entry_items', $insert_ledger_data) then 
                          @db.trans_rollback()
                          @messages.add('Error adding Ledger account - ' + $data_ledger_id + ' to Entry.', 'error')
                          @logger.write_message("error", "Error adding Ledger account item [id:" + $data_ledger_id + "] for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
                          @template.load('template', 'entry/edit', $data)
                          return 
                          
                        $update_data = 
                        'dr_total':$dr_total, 
                        'cr_total':$cr_total, 
                        if not @db.where('id', $entry_id).update('entries', $update_data) then 
                        @db.trans_rollback()
                        @messages.add('Error updating Entry total.', 'error')
                        @logger.write_message("error", "Error updating entry total for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
                        @template.load('template', 'entry/edit', $data)
                        return 
                        @db.trans_complete()#  TODO : Deleting all old ledger data, Bad solution #  Adding ledger accounts #  Updating Debit and Credit Total in entries table #  Success @session.set_userdata('entry_updated_show_action', true)#  Check if atleast one Bank or Cash Ledger account is present #  Updating main entry @session.set_userdata('entry_updated_id', $entry_id)session.set_userdata('entry_updated_type_id', $entry_type_id)
            @session.set_userdata('entry_updated_type_label', $current_entry_type['label'])
            @session.set_userdata('entry_updated_type_name', $current_entry_type['name'])
            @session.set_userdata('entry_updated_number', $data_number)
            if $data_has_reconciliation then @session.set_userdata('entry_updated_has_reconciliation', true)
            else @session.set_userdata('entry_updated_has_reconciliation', false)
            
            #  Showing success message in show() method since message is too long for storing it in session 
            @logger.write_message("success", "Updated " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $data_number) + " [id:" + $entry_id + "]")
            
            redirect('entry/show/' + $current_entry_type['label'])
            return 
            
          return 
          delete : ($entry_type, $entry_id = 0) ->
          #  Check access 
          if not check_access('delete entry') then 
            @messages.add('Permission denied.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Check for account lock 
          if @config.item('account_locked') is 1 then 
            @messages.add('Account is locked.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Entry Type 
          $entry_type_id = entry_type_name_to_id($entry_type)
          if not $entry_type_id then 
            @messages.add('Invalid Entry type.', 'error')
            redirect('entry/show/all')
            return 
            else 
            $current_entry_type = entry_type_info($entry_type_id)
            
          
          #  Load current entry details 
          if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          }
          
          @db.trans_start()
          if not @db.delete('entry_items', 'entry_id':$entry_id) then 
            @db.trans_rollback()
            @messages.add('Error deleting Entry - Ledger accounts.', 'error')
            @logger.write_message("error", "Error deleting ledger entries for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $cur_entry.number) + " [id:" + $entry_id + "]")
            redirect('entry/view/' + $current_entry_type['label'] + '/' + $entry_id)
            return 
            
          if not @db.delete('entries', 'id':$entry_id) then 
            @db.trans_rollback()
            @messages.add('Error deleting Entry entry.', 'error')
            @logger.write_message("error", "Error deleting Entry entry for " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $cur_entry.number) + " [id:" + $entry_id + "]")
            redirect('entry/view/' + $current_entry_type['label'] + '/' + $entry_id)
            return 
            
          @db.trans_complete()
          @messages.add('Deleted ' + $current_entry_type['name'] + ' Entry.', 'success')
          @logger.write_message("success", "Deleted " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $cur_entry.number) + " [id:" + $entry_id + "]")
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          download : ($entry_type, $entry_id = 0) ->
          @load.helper('download')
          @load.model('Setting_model')
          @load.model('Ledger_model')
          
          #  Check access 
          if not check_access('download entry') then 
            @messages.add('Permission denied.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Entry Type 
          $entry_type_id = entry_type_name_to_id($entry_type)
          if not $entry_type_id then 
            @messages.add('Invalid Entry type.', 'error')
            redirect('entry/show/all')
            return 
            else 
            $current_entry_type = entry_type_info($entry_type_id)
            
          
          #  Load current entry details 
          if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          }
          
          $data['entry_type_id'] = $entry_type_id
          $data['current_entry_type'] = $current_entry_type
          $data['entry_number'] = $cur_entry.number
          $data['entry_date'] = date_mysql_to_php_display($cur_entry.date)
          $data['entry_dr_total'] = $cur_entry.dr_total
          $data['entry_cr_total'] = $cur_entry.cr_total
          $data['entry_narration'] = $cur_entry.narration
          
          #  Getting Ledger details 
          @db.from('entry_items').where('entry_id', $entry_id).order_by('dc', 'desc')
          $ledger_q = @db.get()
          $counter = 0
          $data['ledger_data'] = {}
          if $ledger_q.num_rows() > 0 then 
            for $row in $ledger_q.result()
              $data['ledger_data'][$counter] = 
                'id':$row.ledger_id, 
                'name':@Ledger_model.get_name($row.ledger_id,
              'dc':$row.dc, 
              'amount':$row.amount, 
              )
              $counter++
              
            
          
          #  Download Entry 
          $file_name = $current_entry_type['name'] + '_entry_' + $cur_entry.number + ".html"
          $download_data = @load.view('entry/downloadpreview', $data, true)
          force_download($file_name, $download_data)
          return 
          printpreview : ($entry_type, $entry_id = 0) ->
          @load.model('Setting_model')
          @load.model('Ledger_model')
          
          #  Check access 
          if not check_access('print entry') then 
            @messages.add('Permission denied.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Entry Type 
          $entry_type_id = entry_type_name_to_id($entry_type)
          if not $entry_type_id then 
            @messages.add('Invalid Entry type.', 'error')
            redirect('entry/show/all')
            return 
            else 
            $current_entry_type = entry_type_info($entry_type_id)
            
          
          #  Load current entry details 
          if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          }
          
          $data['entry_type_id'] = $entry_type_id
          $data['current_entry_type'] = $current_entry_type
          $data['entry_number'] = $cur_entry.number
          $data['entry_date'] = date_mysql_to_php_display($cur_entry.date)
          $data['entry_dr_total'] = $cur_entry.dr_total
          $data['entry_cr_total'] = $cur_entry.cr_total
          $data['entry_narration'] = $cur_entry.narration
          
          #  Getting Ledger details 
          @db.from('entry_items').where('entry_id', $entry_id).order_by('dc', 'desc')
          $ledger_q = @db.get()
          $counter = 0
          $data['ledger_data'] = {}
          if $ledger_q.num_rows() > 0 then 
            for $row in $ledger_q.result()
              $data['ledger_data'][$counter] = 
                'id':$row.ledger_id, 
                'name':@Ledger_model.get_name($row.ledger_id,
              'dc':$row.dc, 
              'amount':$row.amount, 
              )
              $counter++
              
            
          
          @load.view('entry/printpreview', $data)
          return 
          email : ($entry_type, $entry_id = 0) ->
          @load.model('Setting_model')
          @load.model('Ledger_model')
          @load.library('email')
          
          #  Check access 
          if not check_access('email entry') then 
            @messages.add('Permission denied.', 'error')
            redirect('entry/show/' + $entry_type)
            return 
            
          
          #  Entry Type 
          $entry_type_id = entry_type_name_to_id($entry_type)
          if not $entry_type_id then 
            @messages.add('Invalid Entry type.', 'error')
            redirect('entry/show/all')
            return 
            else 
            $current_entry_type = entry_type_info($entry_type_id)
            
          
          $account_data = @Setting_model.get_current()
          
          #  Load current entry details 
          if not $cur_entry = @Entry_model.get_entry($entry_id, $entry_type_id)) then @messages.add('Invalid Entry.', 'error')
          redirect('entry/show/' + $current_entry_type['label'])
          return 
          }
          
          $data['entry_type_id'] = $entry_type_id
          $data['current_entry_type'] = $current_entry_type
          $data['entry_id'] = $entry_id
          $data['entry_number'] = $cur_entry.number
          $data['email_to'] = 
            'name':'email_to', 
            'id':'email_to', 
            'size':'40', 
            'value':'', 
            
          
          #  Form validations 
          @validation.set_rules('email_to', 'Email to', 'trim|valid_emails|required')
          
          #  Repopulating form 
          if $_POST then 
            $data['email_to']['value'] = @input.post('email_to', true)
            
          
          if @validation.run() is false then
            $data['error'] = validation_errors()
            @load.view('entry/email', $data)
            return 
            
          else 
            $entry_data['entry_type_id'] = $entry_type_id
            $entry_data['current_entry_type'] = $current_entry_type
            $entry_data['entry_number'] = $cur_entry.number
            $entry_data['entry_date'] = date_mysql_to_php_display($cur_entry.date)
            $entry_data['entry_dr_total'] = $cur_entry.dr_total
            $entry_data['entry_cr_total'] = $cur_entry.cr_total
            $entry_data['entry_narration'] = $cur_entry.narration
            
            #  Getting Ledger details 
            @db.from('entry_items').where('entry_id', $entry_id).order_by('dc', 'desc')
            $ledger_q = @db.get()
            $counter = 0
            $entry_data['ledger_data'] = {}
            if $ledger_q.num_rows() > 0 then 
              for $row in $ledger_q.result()
                $entry_data['ledger_data'][$counter] = 
                  'id':$row.ledger_id, 
                  'name':@Ledger_model.get_name($row.ledger_id,
                'dc':$row.dc, 
                'amount':$row.amount, 
                )
                $counter++
                
              
            
            #  Preparing message 
            $message = @load.view('entry/emailpreview', $entry_data, true)
            
            #  Getting email configuration 
            $config['smtp_timeout'] = '30'
            $config['charset'] = 'utf-8'
            $config['newline'] = "\r\n"
            $config['mailtype'] = "html"
            if $account_data then 
              $config['protocol'] = $account_data.email_protocol
              $config['smtp_host'] = $account_data.email_host
              $config['smtp_port'] = $account_data.email_port
              $config['smtp_user'] = $account_data.email_username
              $config['smtp_pass'] = $account_data.email_password
              else 
              $data['error'] = 'Invalid account settings.'
              
            @email.initialize($config)
            
            #  Sending email 
            @email.from('', 'Webzash')
            @email.to(@input.post('email_to', true))
            @email.subject($current_entry_type['name'] + ' Entry No. ' + full_entry_number($entry_type_id, $cur_entry.number))
            @email.message($message)
            if @email.send() then 
              $data['message'] = "Email sent."
              @logger.write_message("success", "Emailed " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $cur_entry.number) + " [id:" + $entry_id + "]")
              else 
              $data['error'] = "Error sending email. Check you email settings."
              @logger.write_message("error", "Error emailing " + $current_entry_type['name'] + " Entry number " + full_entry_number($entry_type_id, $cur_entry.number) + " [id:" + $entry_id + "]")
              
            @load.view('entry/email', $data)
            return 
            
          return 
          addrow : ($add_type = 'all') ->
          $i = time() + rand(0, time()) + rand(0, time()) + rand(0, time())
          $dr_amount = 
            'name':'dr_amount[' + $i + ']', 
            'id':'dr_amount[' + $i + ']', 
            'maxlength':'15', 
            'size':'15', 
            'value':'', 
            'class':'dr-item', 
            'disabled':'disabled', 
            
          $cr_amount = 
            'name':'cr_amount[' + $i + ']', 
            'id':'cr_amount[' + $i + ']', 
            'maxlength':'15', 
            'size':'15', 
            'value':'', 
            'class':'cr-item', 
            'disabled':'disabled', 
            
          
          echo '<tr class="new-row">'
          echo '<td>'
          echo form_dropdown_dc('ledger_dc[' + $i + ']')
          echo '</td>'
          
          echo '<td>'
          if $add_type is 'bankcash' then echo form_input_ledger('ledger_id[' + $i + ']', 0, '', $type = 'bankcash')
          else if $add_type is 'nobankcash' then echo form_input_ledger('ledger_id[' + $i + ']', 0, '', $type = 'nobankcash')
          else echo form_input_ledger('ledger_id[' + $i + ']')
          echo '</td>'
          
          echo '<td>'
          echo form_input($dr_amount)
          echo '</td>'
          echo '<td>'
          echo form_input($cr_amount)
          echo '</td>'
          echo '<td>'
          echo img('src':asset_url( + "images/icons/add.png", 'border':'0', 'alt':'Add Ledger', 'class':'addrow'))
          echo '</td>'
          echo '<td>'
          echo img('src':asset_url( + "images/icons/delete.png", 'border':'0', 'alt':'Remove Ledger', 'class':'deleterow'))
          echo '</td>'
          echo '<td class="ledger-balance"><div></div>'
          echo '</td>'
          echo '</tr>'
          return 
          }
module.exports = Entry