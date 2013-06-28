#+--------------------------------------------------------------------+
#  printer.coffee
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
class Printer extends Controller
  
  Printer :  ->
    parent::Controller()
    @load.model('Setting_model')
    
    #  Check access 
    if not check_access('change account settings') then 
      @messages.add('Permission denied.', 'error')
      redirect('')
      return 
      
    
    return 
    
  
  index :  ->
    @template.set('page_title', 'Printer Settings')
    $account_data = @Setting_model.get_current()
    
    #  Form fields 
    $data['paper_height'] = 
      'name':'paper_height', 
      'id':'paper_height', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['paper_width'] = 
      'name':'paper_width', 
      'id':'paper_width', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['margin_top'] = 
      'name':'margin_top', 
      'id':'margin_top', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['margin_bottom'] = 
      'name':'margin_bottom', 
      'id':'margin_bottom', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['margin_left'] = 
      'name':'margin_left', 
      'id':'margin_left', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['margin_right'] = 
      'name':'margin_right', 
      'id':'margin_right', 
      'maxlength':'10', 
      'size':'10', 
      'value':'', 
      
    $data['orientation_potrait'] = 
      'name':'orientation', 
      'id':'orientation_potrait', 
      'value':'P', 
      'checked':true, 
      
    $data['orientation_landscape'] = 
      'name':'orientation', 
      'id':'orientation_landscape', 
      'value':'L', 
      'checked':false, 
      
    $data['output_format_html'] = 
      'name':'output_format', 
      'id':'output_format_html', 
      'value':'H', 
      'checked':true, 
      
    $data['output_format_text'] = 
      'name':'output_format', 
      'id':'output_format_text', 
      'value':'T', 
      'checked':false, 
      
    
    if $account_data then 
      $data['paper_height']['value'] = if ($account_data.print_paper_height) then print_value($account_data.print_paper_height) else ''
      $data['paper_width']['value'] = if ($account_data.print_paper_width) then print_value($account_data.print_paper_width) else ''
      $data['margin_top']['value'] = if ($account_data.print_margin_top) then print_value($account_data.print_margin_top) else ''
      $data['margin_bottom']['value'] = if ($account_data.print_margin_bottom) then print_value($account_data.print_margin_bottom) else ''
      $data['margin_left']['value'] = if ($account_data.print_margin_left) then print_value($account_data.print_margin_left) else ''
      $data['margin_right']['value'] = if ($account_data.print_margin_right) then print_value($account_data.print_margin_right) else ''
      if $account_data.print_orientation then 
        if $account_data.print_orientation is "P" then 
          $data['orientation_potrait']['checked'] = true
          $data['orientation_landscape']['checked'] = false
          else 
          $data['orientation_potrait']['checked'] = false
          $data['orientation_landscape']['checked'] = true
          
        
      if $account_data.print_page_format then 
        if $account_data.print_page_format is "H" then 
          $data['output_format_html']['checked'] = true
          $data['output_format_text']['checked'] = false
          else 
          $data['output_format_html']['checked'] = false
          $data['output_format_text']['checked'] = true
          
        
      
    
    #  Form validations 
    @validation.set_rules('paper_height', 'Paper Height', 'trim|required|numeric')
    @validation.set_rules('paper_width', 'Paper Width', 'trim|required|numeric')
    @validation.set_rules('margin_top', 'Top Margin', 'trim|required|numeric')
    @validation.set_rules('margin_bottom', 'Bottom Margin', 'trim|required|numeric')
    @validation.set_rules('margin_left', 'Left Margin', 'trim|required|numeric')
    @validation.set_rules('margin_right', 'Right Margin', 'trim|required|numeric')
    
    #  Repopulating form 
    if $_POST then 
      $data['paper_height']['value'] = @input.post('paper_height', true)
      $data['paper_width']['value'] = @input.post('paper_width', true)
      $data['margin_top']['value'] = @input.post('margin_top', true)
      $data['margin_bottom']['value'] = @input.post('margin_bottom', true)
      $data['margin_left']['value'] = @input.post('margin_left', true)
      $data['margin_right']['value'] = @input.post('margin_right', true)
      
      $data['orientation'] = @input.post('orientation', true)
      if $data['orientation'] is "P" then 
        $data['orientation_potrait']['checked'] = true
        $data['orientation_landscape']['checked'] = false
        else 
        $data['orientation_potrait']['checked'] = false
        $data['orientation_landscape']['checked'] = true
        
      $data['output_format'] = @input.post('output_format', true)
      if $data['output_format'] is "H" then 
        $data['output_format_html']['checked'] = true
        $data['output_format_text']['checked'] = false
        else 
        $data['output_format_html']['checked'] = false
        $data['output_format_text']['checked'] = true
        
      
    
    #  Validating form 
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'setting/printer', $data)
      return 
      
    else 
      $data_paper_height = @input.post('paper_height', true)
      $data_paper_width = @input.post('paper_width', true)
      $data_margin_top = @input.post('margin_top', true)
      $data_margin_bottom = @input.post('margin_bottom', true)
      $data_margin_left = @input.post('margin_left', true)
      $data_margin_right = @input.post('margin_right', true)
      
      if @input.post('orientation', true) is "P" then 
        $data_orientation = "P"
        else 
        $data_orientation = "L"
        
      if @input.post('output_format', true) is "H" then 
        $data_output_format = "H"
        else 
        $data_output_format = "T"
        
      
      #  Update settings 
      @db.trans_start()
      $update_data = 
        'print_paper_height':$data_paper_height, 
        'print_paper_width':$data_paper_width, 
        'print_margin_top':$data_margin_top, 
        'print_margin_bottom':$data_margin_bottom, 
        'print_margin_left':$data_margin_left, 
        'print_margin_right':$data_margin_right, 
        'print_orientation':$data_orientation, 
        'print_page_format':$data_output_format, 
        
      if not @db.where('id', 1).update('settings', $update_data) then 
        @db.trans_rollback()
        @messages.add('Error updating printer settings.', 'error')
        @logger.write_message("error", "Error updating printer settings")
        @template.load('template', 'setting/printer')
        return 
        else 
        @db.trans_complete()
        @messages.add('Printer settings updated.', 'success')
        @logger.write_message("success", "Updated printer settings")
        redirect('setting')
        return 
        
      
    return 
    
  
module.exports = Printer

#  End of file printer.php 
#  Location: ./system/application/controllers/setting/printer.php 
