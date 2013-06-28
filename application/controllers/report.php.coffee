#+--------------------------------------------------------------------+
#  report.coffee
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
class Report extends Controller
  acc_array: {}
  account_counter: {}
  Report :  ->
    parent::Controller()
    @load.model('Ledger_model')
    
    #  Check access 
    if not check_access('view reports') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Reports')
    @template.load('template', 'report/index')
    return 
    
  
  balancesheet : ($period = null) ->
    @template.set('page_title', 'Balance Sheet')
    @template.set('nav_links', 'report/download/balancesheet':'Download CSV', 'report/printpreview/balancesheet':'Print Preview')
    $data['left_width'] = "450"
    $data['right_width'] = "450"
    @template.load('template', 'report/balancesheet', $data)
    return 
    
  
  profitandloss : ($period = null) ->
    @template.set('page_title', 'Profit And Loss Statement')
    @template.set('nav_links', 'report/download/profitandloss':'Download CSV', 'report/printpreview/profitandloss':'Print Preview')
    $data['left_width'] = "450"
    $data['right_width'] = "450"
    @template.load('template', 'report/profitandloss', $data)
    return 
    
  
  trialbalance : ($period = null) ->
    @template.set('page_title', 'Trial Balance')
    @template.set('nav_links', 'report/download/trialbalance':'Download CSV', 'report/printpreview/trialbalance':'Print Preview')
    
    @load.library('accountlist')
    @template.load('template', 'report/trialbalance')
    return 
    
  
  ledgerst : ($ledger_id = 0) ->
    @load.helper('text')
    
    #  Pagination setup 
    @load.library('pagination')
    
    @template.set('page_title', 'Ledger Statement')
    if $ledger_id isnt 0 then @template.set('nav_links', 'report/download/ledgerst/' + $ledger_id:'Download CSV', 'report/printpreview/ledgerst/' + $ledger_id:'Print Preview')
    
    if $_POST then 
      $ledger_id = @input.post('ledger_id', true)
      redirect('report/ledgerst/' + $ledger_id)
      
    $data['print_preview'] = false
    $data['ledger_id'] = $ledger_id
    
    #  Checking for valid ledger id 
    if $data['ledger_id'] > 0 then 
      @db.from('ledgers').where('id', $data['ledger_id']).limit(1)
      if @db.get().num_rows() < 1 then 
        @messages.add('Invalid Ledger account.', 'error')
        redirect('report/ledgerst')
        return 
        
      else if $data['ledger_id'] < 0 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('report/ledgerst')
      return 
      
    
    @template.load('template', 'report/ledgerst', $data)
    return 
    
  
  reconciliation : ($reconciliation_type = '', $ledger_id = 0) ->
    @load.helper('text')
    
    #  Pagination setup 
    @load.library('pagination')
    
    @template.set('page_title', 'Reconciliation')
    
    #  Check if path is 'all' or 'pending' 
    $data['show_all'] = false
    $data['print_preview'] = false
    $data['ledger_id'] = $ledger_id
    if $reconciliation_type is 'all' then 
      $data['reconciliation_type'] = 'all'
      $data['show_all'] = true
      if $ledger_id > 0 then @template.set('nav_links', 'report/download/reconciliation/' + $ledger_id + '/all':'Download CSV', 'report/printpreview/reconciliation/' + $ledger_id + '/all':'Print Preview')
      else if $reconciliation_type is 'pending' then 
      $data['reconciliation_type'] = 'pending'
      $data['show_all'] = false
      if $ledger_id > 0 then @template.set('nav_links', 'report/download/reconciliation/' + $ledger_id + '/pending':'Download CSV', 'report/printpreview/reconciliation/' + $ledger_id + '/pending':'Print Preview')
      else 
      @messages.add('Invalid path.', 'error')
      redirect('report/reconciliation/pending')
      return 
      
    
    #  Checking for valid ledger id and reconciliation status 
    if $data['ledger_id'] > 0 then 
      @db.from('ledgers').where('id', $data['ledger_id']).where('reconciliation', 1).limit(1)
      if @db.get().num_rows() < 1 then 
        @messages.add('Invalid Ledger account or Reconciliation is not enabled for the Ledger account.', 'error')
        redirect('report/reconciliation/' + $reconciliation_type)
        return 
        
      else if $data['ledger_id'] < 0 then 
      @messages.add('Invalid Ledger account.', 'error')
      redirect('report/reconciliation/' + $reconciliation_type)
      return 
      
    
    if $_POST then 
      #  Check if Ledger account is changed or reconciliation is updated 
      if $_POST['submit'] is 'Submit' then 
        $ledger_id = @input.post('ledger_id', true)
        if @input.post('show_all', true) then 
          redirect('report/reconciliation/all/' + $ledger_id)
          return 
          else 
          redirect('report/reconciliation/pending/' + $ledger_id)
          return 
          
        else if $_POST['submit'] is 'Update' then 
        
        $data_reconciliation_date = @input.post('reconciliation_date', true)
        
        #  Form validations 
        for $id, $row of $data_reconciliation_date
          #  If reconciliation date is present then check for valid date else only trim 
          if $row then @validation.set_rules('reconciliation_date[' + $id + ']', 'Reconciliation date', 'trim|required|is_date|is_date_within_range_reconcil')
          else @validation.set_rules('reconciliation_date[' + $id + ']', 'Reconciliation date', 'trim')
          
        
        if @validation.run() is false then
          @messages.add(validation_errors(), 'error')
          @template.load('template', 'report/reconciliation', $data)
          return 
          else 
          #  Updating reconciliation date 
          for $id, $row of $data_reconciliation_date
            @db.trans_start()
            if $row then 
              $update_data = 
                'reconciliation_date':date_php_to_mysql($row,
              )
              else 
              $update_data = 
                'reconciliation_date':null, 
                
              
            if not @db.where('id', $id).update('entry_items', $update_data) then 
              @db.trans_rollback()
              @messages.add('Error updating reconciliation.', 'error')
              @logger.write_message("error", "Error updating reconciliation for entry item [id:" + $id + "]")
              else 
              @db.trans_complete()
              
            
          @messages.add('Updated reconciliation.', 'success')
          @logger.write_message("success", 'Updated reconciliation.')
          
        
      
    @template.load('template', 'report/reconciliation', $data)
    return 
    
  
  download : ($statement, $id = null) ->
    # ******************** TRIAL BALANCE ***********************
    if $statement is "trialbalance" then 
      @load.model('Ledger_model')
      $all_ledgers = @Ledger_model.get_all_ledgers()
      $counter = 0
      $trialbalance = {}
      $temp_dr_total = 0
      $temp_cr_total = 0
      
      $trialbalance[$counter] = ["TRIAL BALANCE", "", "", "", "", "", "", "", ""]
      $counter++
      $trialbalance[$counter] = ["FY " + date_mysql_to_php(@config.item('account_fy_start']) + " - " + date_mysql_to_php(@config.item('account_fy_end')), "", "", "", "", "", "", "", "")
      $counter++
      
      $trialbalance[$counter][0] = "Ledger"
      $trialbalance[$counter][1] = ""
      $trialbalance[$counter][2] = "Opening"
      $trialbalance[$counter][3] = ""
      $trialbalance[$counter][4] = "Closing"
      $trialbalance[$counter][5] = ""
      $trialbalance[$counter][6] = "Dr Total"
      $trialbalance[$counter][7] = ""
      $trialbalance[$counter][8] = "Cr Total"
      $counter++
      
      for $ledger_id, $ledger_name of $all_ledgers
        if $ledger_id is 0 then continue
        
        $trialbalance[$counter][0] = $ledger_name
        
        [$opbal_amount, $opbal_type] = @Ledger_model.get_op_balance($ledger_id)
        if float_ops($opbal_amount, 0, '==') then 
          $trialbalance[$counter][1] = ""
          $trialbalance[$counter][2] = 0
          else 
          $trialbalance[$counter][1] = convert_dc($opbal_type)
          $trialbalance[$counter][2] = $opbal_amount
          
        
        $clbal_amount = @Ledger_model.get_ledger_balance($ledger_id)
        
        if float_ops($clbal_amount, 0, '==') then 
          $trialbalance[$counter][3] = ""
          $trialbalance[$counter][4] = 0
          else if $clbal_amount < 0 then 
          $trialbalance[$counter][3] = "Cr"
          $trialbalance[$counter][4] = convert_cur( - $clbal_amount)
          else 
          $trialbalance[$counter][3] = "Dr"
          $trialbalance[$counter][4] = convert_cur($clbal_amount)
          
        
        $dr_total = @Ledger_model.get_dr_total($ledger_id)
        if $dr_total then 
          $trialbalance[$counter][5] = "Dr"
          $trialbalance[$counter][6] = convert_cur($dr_total)
          $temp_dr_total = float_ops($temp_dr_total, $dr_total, '+')
          else 
          $trialbalance[$counter][5] = ""
          $trialbalance[$counter][6] = 0
          
        
        $cr_total = @Ledger_model.get_cr_total($ledger_id)
        if $cr_total then 
          $trialbalance[$counter][7] = "Cr"
          $trialbalance[$counter][8] = convert_cur($cr_total)
          $temp_cr_total = float_ops($temp_cr_total, $cr_total, '+')
          else 
          $trialbalance[$counter][7] = ""
          $trialbalance[$counter][8] = 0
          
        $counter++
        
      
      $trialbalance[$counter][0] = ""
      $trialbalance[$counter][1] = ""
      $trialbalance[$counter][2] = ""
      $trialbalance[$counter][3] = ""
      $trialbalance[$counter][4] = ""
      $trialbalance[$counter][5] = ""
      $trialbalance[$counter][6] = ""
      $trialbalance[$counter][7] = ""
      $trialbalance[$counter][8] = ""
      $counter++
      
      $trialbalance[$counter][0] = "Total"
      $trialbalance[$counter][1] = ""
      $trialbalance[$counter][2] = ""
      $trialbalance[$counter][3] = ""
      $trialbalance[$counter][4] = ""
      $trialbalance[$counter][5] = "Dr"
      $trialbalance[$counter][6] = convert_cur($temp_dr_total)
      $trialbalance[$counter][7] = "Cr"
      $trialbalance[$counter][8] = convert_cur($temp_cr_total)
      
      @load.helper('csv')
      echo array_to_csv($trialbalance, "trialbalance.csv")
      return 
      
    
    # ******************** LEDGER STATEMENT ********************
    if $statement is "ledgerst" then 
      @load.helper('text')
      $ledger_id = @uri.segment(4)
      if $ledger_id < 1 then return @load.model('Ledger_model')
      $cur_balance = 0
      $counter = 0
      $ledgerst = {}
      
      $ledgerst[$counter] = ["", "", "LEDGER STATEMENT FOR " + strtoupper(@Ledger_model.get_name($ledger_id]), "", "", "", "", "", "", "", "")
      $counter++
      $ledgerst[$counter] = ["", "", "FY " + date_mysql_to_php(@config.item('account_fy_start']) + " - " + date_mysql_to_php(@config.item('account_fy_end')), "", "", "", "", "", "", "", "")
      $counter++
      
      $ledgerst[$counter][0] = "Date"
      $ledgerst[$counter][1] = "Number"
      $ledgerst[$counter][2] = "Ledger Name"
      $ledgerst[$counter][3] = "Narration"
      $ledgerst[$counter][4] = "Type"
      $ledgerst[$counter][5] = ""
      $ledgerst[$counter][6] = "Dr Amount"
      $ledgerst[$counter][7] = ""
      $ledgerst[$counter][8] = "Cr Amount"
      $ledgerst[$counter][9] = ""
      $ledgerst[$counter][10] = "Balance"
      $counter++
      
      #  Opening Balance 
      [$opbalance, $optype] = @Ledger_model.get_op_balance($ledger_id)
      $ledgerst[$counter] = ["Opening Balance", "", "", "", "", "", "", "", "", convert_dc($optype],$opbalance)
      if $optype is "D" then $cur_balance = float_ops($cur_balance, $opbalance, '+')else $cur_balance = float_ops($cur_balance, $opbalance, '-')$counter++@db.select('entries.id as entries_id, entries.number as entries_number, entries.date as entries_date, entries.narration as entries_narration, entries.entry_type as entries_entry_type, entry_items.amount as entry_items_amount, entry_items.dc as entry_items_dc')
      @db.from('entries').join('entry_items', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).order_by('entries.date', 'asc').order_by('entries.number', 'asc')
      $ledgerst_q = @db.get()
      for $row in $ledgerst_q.result()
        #  Entry Type 
        $current_entry_type = entry_type_info($row.entries_entry_type)
        
        $ledgerst[$counter][0] = date_mysql_to_php($row.entries_date)
        $ledgerst[$counter][1] = full_entry_number($row.entries_entry_type, $row.entries_number)
        
        #  Opposite entry name 
        $ledgerst[$counter][2] = @Ledger_model.get_opp_ledger_name($row.entries_id, $current_entry_type['label'], $row.entry_items_dc, 'text')
        $ledgerst[$counter][3] = $row.entries_narration
        $ledgerst[$counter][4] = $current_entry_type['name']
        
        if $row.entry_items_dc is "D" then 
          $cur_balance = float_ops($cur_balance, $row.entry_items_amount, '+')
          $ledgerst[$counter][5] = convert_dc($row.entry_items_dc)
          $ledgerst[$counter][6] = $row.entry_items_amount
          $ledgerst[$counter][7] = ""
          $ledgerst[$counter][8] = ""
          
          else 
          $cur_balance = float_ops($cur_balance, $row.entry_items_amount, '-')
          $ledgerst[$counter][5] = ""
          $ledgerst[$counter][6] = ""
          $ledgerst[$counter][7] = convert_dc($row.entry_items_dc)
          $ledgerst[$counter][8] = $row.entry_items_amount
          
        
        if float_ops($cur_balance, 0, '==') then 
          $ledgerst[$counter][9] = ""
          $ledgerst[$counter][10] = 0
          else if float_ops($cur_balance, 0, '<') then 
          $ledgerst[$counter][9] = "Cr"
          $ledgerst[$counter][10] = convert_cur( - $cur_balance)
          else 
          $ledgerst[$counter][9] = "Dr"
          $ledgerst[$counter][10] = convert_cur($cur_balance)
          
        $counter++
        
      
      $ledgerst[$counter][0] = "Closing Balance"
      $ledgerst[$counter][1] = ""
      $ledgerst[$counter][2] = ""
      $ledgerst[$counter][3] = ""
      $ledgerst[$counter][4] = ""
      $ledgerst[$counter][5] = ""
      $ledgerst[$counter][6] = ""
      $ledgerst[$counter][7] = ""
      $ledgerst[$counter][8] = ""
      if float_ops($cur_balance, 0, '<') then 
        $ledgerst[$counter][9] = "Cr"
        $ledgerst[$counter][10] = convert_cur( - $cur_balance)
        else 
        $ledgerst[$counter][9] = "Dr"
        $ledgerst[$counter][10] = convert_cur($cur_balance)
        
      $counter++
      
      $ledgerst[$counter] = ["", "", "", "", "", "", "", "", "", "", ""]
      $counter++
      
      #  Final Opening and Closing Balance 
      $clbalance = @Ledger_model.get_ledger_balance($ledger_id)
      
      $ledgerst[$counter] = ["Opening Balance", convert_dc($optype],$opbalance, "", "", "", "", "", "", "", "")
      $counter++
      
      if float_ops($clbalance, 0, '==') then $ledgerst[$counter] = ["Closing Balance", "", 0, "", "", "", "", "", "", "", ""]else if $clbalance < 0 then $ledgerst[$counter] = ["Closing Balance", "Cr", convert_cur( - $clbalance],"", "", "", "", "", "", "", "")else $ledgerst[$counter] = ["Closing Balance", "Dr", convert_cur($clbalance],"", "", "", "", "", "", "", "")@load.helper('csv')
      echo array_to_csv($ledgerst, "ledgerst.csv")
      return 
      
    
    # ******************** RECONCILIATION **********************
    if $statement is "reconciliation" then 
      $ledger_id = @uri.segment(4)
      $reconciliation_type = @uri.segment(5)
      
      if $ledger_id < 1 then return if not (($reconciliation_type is 'all') or ($reconciliation_type is 'pending')) then return @load.model('Ledger_model')$cur_balance = 0$counter = 0$ledgerst = {}$ledgerst[$counter] = ["", "", "RECONCILIATION STATEMENT FOR " + strtoupper(@Ledger_model.get_name($ledger_id]), "", "", "", "", "", "", "")
      $counter++
      $ledgerst[$counter] = ["", "", "FY " + date_mysql_to_php(@config.item('account_fy_start']) + " - " + date_mysql_to_php(@config.item('account_fy_end')), "", "", "", "", "", "", "")
      $counter++
      
      $ledgerst[$counter][0] = "Date"
      $ledgerst[$counter][1] = "Number"
      $ledgerst[$counter][2] = "Ledger Name"
      $ledgerst[$counter][3] = "Narration"
      $ledgerst[$counter][4] = "Type"
      $ledgerst[$counter][5] = ""
      $ledgerst[$counter][6] = "Dr Amount"
      $ledgerst[$counter][7] = ""
      $ledgerst[$counter][8] = "Cr Amount"
      $ledgerst[$counter][9] = "Reconciliation Date"
      $counter++
      
      #  Opening Balance 
      [$opbalance, $optype] = @Ledger_model.get_op_balance($ledger_id)
      
      @db.select('entries.id as entries_id, entries.number as entries_number, entries.date as entries_date, entries.narration as entries_narration, entries.entry_type as entries_entry_type, entry_items.amount as entry_items_amount, entry_items.dc as entry_items_dc, entry_items.reconciliation_date as entry_items_reconciliation_date')
      if $reconciliation_type is 'all' then @db.from('entries').join('entry_items', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).order_by('entries.date', 'asc').order_by('entries.number', 'asc')
      else @db.from('entries').join('entry_items', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).where('entry_items.reconciliation_date', null).order_by('entries.date', 'asc').order_by('entries.number', 'asc')
      $ledgerst_q = @db.get()
      for $row in $ledgerst_q.result()
        #  Entry Type 
        $current_entry_type = entry_type_info($row.entries_entry_type)
        
        $ledgerst[$counter][0] = date_mysql_to_php($row.entries_date)
        $ledgerst[$counter][1] = full_entry_number($row.entries_entry_type, $row.entries_number)
        
        #  Opposite entry name 
        $ledgerst[$counter][2] = @Ledger_model.get_opp_ledger_name($row.entries_id, $current_entry_type['label'], $row.entry_items_dc, 'text')
        $ledgerst[$counter][3] = $row.entries_narration
        $ledgerst[$counter][4] = $current_entry_type['name']
        
        if $row.entry_items_dc is "D" then 
          $ledgerst[$counter][5] = convert_dc($row.entry_items_dc)
          $ledgerst[$counter][6] = $row.entry_items_amount
          $ledgerst[$counter][7] = ""
          $ledgerst[$counter][8] = ""
          
          else 
          $ledgerst[$counter][5] = ""
          $ledgerst[$counter][6] = ""
          $ledgerst[$counter][7] = convert_dc($row.entry_items_dc)
          $ledgerst[$counter][8] = $row.entry_items_amount
          
        
        if $row.entry_items_reconciliation_date then 
          $ledgerst[$counter][9] = date_mysql_to_php($row.entry_items_reconciliation_date)
          else 
          $ledgerst[$counter][9] = ""
          
        $counter++
        
      
      $counter++
      $ledgerst[$counter] = ["", "", "", "", "", "", "", "", "", ""]
      $counter++
      
      #  Final Opening and Closing Balance 
      $clbalance = @Ledger_model.get_ledger_balance($ledger_id)
      
      $ledgerst[$counter] = ["Opening Balance", convert_dc($optype],$opbalance, "", "", "", "", "", "", "")
      $counter++
      
      if float_ops($clbalance, 0, '==') then $ledgerst[$counter] = ["Closing Balance", "", 0, "", "", "", "", "", "", ""]else if float_ops($clbalance, 0, '<') then $ledgerst[$counter] = ["Closing Balance", "Cr", convert_cur( - $clbalance],"", "", "", "", "", "", "")else $ledgerst[$counter] = ["Closing Balance", "Dr", convert_cur($clbalance],"", "", "", "", "", "", "")@db.select_sum('amount', 'drtotal').from('entry_items').join('entries', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).where('entry_items.dc', 'D').where('entry_items.reconciliation_date IS NOT NULL')# *********** Final Reconciliation Balance *********#  Reconciliation Balance - Dr 
      $dr_total_q = @db.get()
      if $dr_total = $dr_total_q.row()) then  = $dr_total.drtotalelse #  Reconciliation Balance - Cr $reconciliation_dr_total = 0@db.select_sum('amount', 'crtotal').from('entry_items').join('entries', 'entries.id = entry_items.entry_id').where('entry_items.ledger_id', $ledger_id).where('entry_items.dc', 'C').where('entry_items.reconciliation_date IS NOT NULL')$cr_total_q = @db.get()if $cr_total = $cr_total_q.row()) then  = $cr_total.crtotalelse $reconciliation_cr_total = 0$reconciliation_total = float_ops($reconciliation_dr_total, $reconciliation_cr_total, '-')$reconciliation_pending = float_ops($clbalance, $reconciliation_total, '-')$counter++if float_ops($reconciliation_pending, 0, '==') then $ledgerst[$counter] = ["Reconciliation Pending", "", 0, "", "", "", "", "", "", ""]else if float_ops($reconciliation_pending, 0, '<') then $ledgerst[$counter] = ["Reconciliation Pending", "Cr", convert_cur( - $reconciliation_pending],"", "", "", "", "", "", "")else $ledgerst[$counter] = ["Reconciliation Pending", "Dr", convert_cur($reconciliation_pending],"", "", "", "", "", "", "")$counter++if float_ops($reconciliation_total, 0, '==') then $ledgerst[$counter] = ["Reconciliation Total", "", 0, "", "", "", "", "", "", ""]else if float_ops($reconciliation_total, 0, '<') then $ledgerst[$counter] = ["Reconciliation Total", "Cr", convert_cur( - $reconciliation_total],"", "", "", "", "", "", "")else $ledgerst[$counter] = ["Reconciliation Total", "Dr", convert_cur($reconciliation_total],"", "", "", "", "", "", "")@load.helper('csv')echo array_to_csv($ledgerst, "reconciliation.csv")return }if $statement is "balancesheet" then 
        @load.library('accountlist')
        @load.model('Ledger_model')
        
        $liability = new Accountlist()
        $liability.init(2)
        $liability_array = $liability.build_array()
        $liability_depth = Accountlist::$max_depth
        $liability_total =  - $liability.total
        
        Accountlist::reset_max_depth()
        
        $asset = new Accountlist()
        $asset.init(1)
        $asset_array = $asset.build_array()
        $asset_depth = Accountlist::$max_depth
        $asset_total = $asset.total
        
        $liability.to_csv($liability_array)
        Accountlist::add_blank_csv()
        $asset.to_csv($asset_array)
        
        $income = new Accountlist()
        $income.init(3)
        $expense = new Accountlist()
        $expense.init(4)
        $income_total =  - $income.total
        $expense_total = $expense.total
        $pandl = float_ops($income_total, $expense_total, '-')
        $diffop = @Ledger_model.get_diff_op_balance()
        
        Accountlist::add_blank_csv()
        #  Liability side 
        $total = $liability_total
        Accountlist::add_row_csv(["Liabilities and Owners Equity Total", convert_cur($liability_total]))
        
        #  If Profit then Liability side, If Loss then Asset side 
        if float_ops($pandl, 0, '!=') then 
          if float_ops($pandl, 0, '>') then 
            $total = float_ops($total, $pandl, '+')
            Accountlist::add_row_csv(["Profit & Loss Account (Net Profit)", convert_cur($pandl]))
            
          
        
        #  If Op balance Dr then Liability side, If Op balance Cr then Asset side 
        if float_ops($diffop, 0, '!=') then 
          if float_ops($diffop, 0, '>') then 
            $total = float_ops($total, $diffop, '+')
            Accountlist::add_row_csv(["Diff in O/P Balance", "Dr " + convert_cur($diffop]))
            
          
        
        Accountlist::add_row_csv(["Total - Liabilities and Owners Equity", convert_cur($total]))
        
        #  Asset side 
        $total = $asset_total
        Accountlist::add_row_csv(["Asset Total", convert_cur($asset_total]))
        
        #  If Profit then Liability side, If Loss then Asset side 
        if float_ops($pandl, 0, '!=') then 
          if float_ops($pandl, 0, '<') then 
            $total = float_ops($total,  - $pandl, '+')
            Accountlist::add_row_csv(["Profit & Loss Account (Net Loss)", convert_cur( - $pandl]))
            
          
        
        #  If Op balance Dr then Liability side, If Op balance Cr then Asset side 
        if float_ops($diffop, 0, '!=') then 
          if float_ops($diffop, 0, '<') then 
            $total = float_ops($total,  - $diffop, '+')
            Accountlist::add_row_csv(["Diff in O/P Balance", "Cr " + convert_cur( - $diffop]))
            
          
        
        Accountlist::add_row_csv(["Total - Assets", convert_cur($total]))
        
        $balancesheet = Accountlist::get_csv()
        @load.helper('csv')
        echo array_to_csv($balancesheet, "balancesheet.csv")
        return 
        if $statement is "profitandloss" then 
        @load.library('accountlist')
        @load.model('Ledger_model')
        
        # *************** GROSS CALCULATION ****************
        
        #  Gross P/L : Expenses 
        $gross_expense_total = 0
        @db.from('groups').where('parent_id', 4).where('affects_gross', 1)
        $gross_expense_list_q = @db.get()
        for $row in $gross_expense_list_q.result()
          $gross_expense = new Accountlist()
          $gross_expense.init($row.id)
          $gross_expense_total = float_ops($gross_expense_total, $gross_expense.total, '+')
          $gross_exp_array = $gross_expense.build_array()
          $gross_expense.to_csv($gross_exp_array)
          
        Accountlist::add_blank_csv()
        
        #  Gross P/L : Incomes 
        $gross_income_total = 0
        @db.from('groups').where('parent_id', 3).where('affects_gross', 1)
        $gross_income_list_q = @db.get()
        for $row in $gross_income_list_q.result()
          $gross_income = new Accountlist()
          $gross_income.init($row.id)
          $gross_income_total = float_ops($gross_income_total, $gross_income.total, '+')
          $gross_inc_array = $gross_income.build_array()
          $gross_income.to_csv($gross_inc_array)
          
        
        Accountlist::add_blank_csv()
        Accountlist::add_blank_csv()
        
        #  Converting to positive value since Cr 
        $gross_income_total =  - $gross_income_total
        
        #  Calculating Gross P/L 
        $grosspl = float_ops($gross_income_total, $gross_expense_total, '-')
        
        #  Showing Gross P/L : Expenses 
        $grosstotal = $gross_expense_total
        Accountlist::add_row_csv(["Total Gross Expenses", convert_cur($gross_expense_total]))
        if float_ops($grosspl, 0, '>') then 
          $grosstotal = float_ops($grosstotal, $grosspl, '+')
          Accountlist::add_row_csv(["Gross Profit C/O", convert_cur($grosspl]))
          
        Accountlist::add_row_csv(["Total Expenses - Gross", convert_cur($grosstotal]))
        
        #  Showing Gross P/L : Incomes  
        $grosstotal = $gross_income_total
        Accountlist::add_row_csv(["Total Gross Incomes", convert_cur($gross_income_total]))
        
        if float_ops($grosspl, 0, '>') then 
          
          else if float_ops($grosspl, 0, '<') then 
          $grosstotal = float_ops($grosstotal,  - $grosspl, '+')
          Accountlist::add_row_csv(["Gross Loss C/O", convert_cur( - $grosspl]))
          
        Accountlist::add_row_csv(["Total Incomes - Gross", convert_cur($grosstotal]))
        
        # *********************** NET CALCULATIONS *************************
        
        Accountlist::add_blank_csv()
        Accountlist::add_blank_csv()
        
        #  Net P/L : Expenses 
        $net_expense_total = 0
        @db.from('groups').where('parent_id', 4).where('affects_gross !=', 1)
        $net_expense_list_q = @db.get()
        for $row in $net_expense_list_q.result()
          $net_expense = new Accountlist()
          $net_expense.init($row.id)
          $net_expense_total = float_ops($net_expense_total, $net_expense.total, '+')
          $net_exp_array = $net_expense.build_array()
          $net_expense.to_csv($net_exp_array)
          
        Accountlist::add_blank_csv()
        
        #  Net P/L : Incomes 
        $net_income_total = 0
        @db.from('groups').where('parent_id', 3).where('affects_gross !=', 1)
        $net_income_list_q = @db.get()
        for $row in $net_income_list_q.result()
          $net_income = new Accountlist()
          $net_income.init($row.id)
          $net_income_total = float_ops($net_income_total, $net_income.total, '+')
          $net_inc_array = $net_income.build_array()
          $net_income.to_csv($net_inc_array)
          
        
        Accountlist::add_blank_csv()
        Accountlist::add_blank_csv()
        
        #  Converting to positive value since Cr 
        $net_income_total =  - $net_income_total
        
        #  Calculating Net P/L 
        $netpl = float_ops(float_ops($net_income_total, $net_expense_total, '-'), $grosspl, '+')
        
        #  Showing Net P/L : Expenses 
        $nettotal = $net_expense_total
        Accountlist::add_row_csv(["Total Expenses", convert_cur($nettotal]))
        
        if float_ops($grosspl, 0, '>') then 
          else if float_ops($grosspl, 0, '<') then 
          $nettotal = float_ops($nettotal,  - $grosspl, '+')
          Accountlist::add_row_csv(["Gross Loss B/F", convert_cur( - $grosspl]))
          
        if float_ops($netpl, 0, '>') then 
          $nettotal = float_ops($nettotal, $netpl, '+')
          Accountlist::add_row_csv(["Net Profit", convert_cur($netpl]))
          
        Accountlist::add_row_csv(["Total - Net Expenses", convert_cur($nettotal]))
        
        #  Showing Net P/L : Incomes 
        $nettotal = $net_income_total
        Accountlist::add_row_csv(["Total Incomes", convert_cur($nettotal]))
        
        if $grosspl > 0 then 
          $nettotal = float_ops($nettotal, $grosspl, '+')
          Accountlist::add_row_csv(["Gross Profit B/F", convert_cur($grosspl]))
          
        
        if $netpl > 0 then 
          
          else if $netpl < 0 then 
          $nettotal = float_ops($nettotal,  - $netpl, '+')
          Accountlist::add_row_csv(["Net Loss", convert_cur( - $netpl]))
          
        Accountlist::add_row_csv(["Total - Net Incomes", convert_cur($nettotal]))
        
        $balancesheet = Accountlist::get_csv()
        @load.helper('csv')
        echo array_to_csv($balancesheet, "profitandloss.csv")
        return 
        return }printpreview : ($statement, $id = null) ->
        # ******************** TRIAL BALANCE ***********************
        if $statement is "trialbalance" then 
          @load.library('accountlist')
          $data['report'] = "report/trialbalance"
          $data['title'] = "Trial Balance"
          @load.view('report/report_template', $data)
          return 
          
        
        if $statement is "balancesheet" then 
          $data['report'] = "report/balancesheet"
          $data['title'] = "Balance Sheet"
          $data['left_width'] = ""
          $data['right_width'] = ""
          @load.view('report/report_template', $data)
          return 
          
        
        if $statement is "profitandloss" then 
          $data['report'] = "report/profitandloss"
          $data['title'] = "Profit and Loss Statement"
          $data['left_width'] = ""
          $data['right_width'] = ""
          @load.view('report/report_template', $data)
          return 
          
        
        if $statement is "ledgerst" then 
          @load.helper('text')
          
          #  Pagination setup 
          @load.library('pagination')
          $data['ledger_id'] = @uri.segment(4)
          #  Checking for valid ledger id 
          if $data['ledger_id'] < 1 then 
            @messages.add('Invalid Ledger account.', 'error')
            redirect('report/ledgerst')
            return 
            
          @db.from('ledgers').where('id', $data['ledger_id']).limit(1)
          if @db.get().num_rows() < 1 then 
            @messages.add('Invalid Ledger account.', 'error')
            redirect('report/ledgerst')
            return 
            
          $data['report'] = "report/ledgerst"
          $data['title'] = "Ledger Statement for '" + @Ledger_model.get_name($data['ledger_id']) + "'"
          $data['print_preview'] = true
          @load.view('report/report_template', $data)
          return 
          
        
        if $statement is "reconciliation" then 
          @load.helper('text')
          
          $data['show_all'] = false
          $data['ledger_id'] = @uri.segment(4)
          
          #  Check if path is 'all' or 'pending' 
          if @uri.segment(5) is 'all' then 
            $data['reconciliation_type'] = 'all'
            $data['show_all'] = true
            else if @uri.segment(5) is 'pending' then 
            $data['reconciliation_type'] = 'pending'
            $data['show_all'] = false
            else 
            @messages.add('Invalid path.', 'error')
            redirect('report/reconciliation/pending')
            return 
            
          
          #  Checking for valid ledger id and reconciliation status 
          if $data['ledger_id'] > 0 then 
            @db.from('ledgers').where('id', $data['ledger_id']).where('reconciliation', 1).limit(1)
            if @db.get().num_rows() < 1 then 
              @messages.add('Invalid Ledger account or Reconciliation is not enabled for the Ledger account.', 'error')
              redirect('report/reconciliation/' + $reconciliation_type)
              return 
              
            else if $data['ledger_id'] < 0 then 
            @messages.add('Invalid Ledger account.', 'error')
            redirect('report/reconciliation/' + $reconciliation_type)
            return 
            
          
          $data['report'] = "report/reconciliation"
          $data['title'] = "Reconciliation Statement for '" + @Ledger_model.get_name($data['ledger_id']) + "'"
          $data['print_preview'] = true
          @load.view('report/report_template', $data)
          return 
          
        return 
        }# ********************** BALANCE SHEET *********************# ******************** PROFIT AND LOSS *********************#  End of file report.php #  Location: ./system/application/controllers/report.php 
module.exports = Report