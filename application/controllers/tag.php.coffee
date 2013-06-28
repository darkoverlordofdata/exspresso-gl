#+--------------------------------------------------------------------+
#  tag.coffee
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
class Tag extends Controller
  
  Tag :  ->
    parent::Controller()
    return 
    
  
  index :  ->
    @load.model('Tag_model')
    @template.set('page_title', 'Tags')
    @template.set('nav_links', 'tag/add':'New Tag')
    @template.load('template', 'tag/index')
    return 
    
  
  add :  ->
    @template.set('page_title', 'New Tag')
    
    #  Check access 
    if not check_access('create tag') then 
      @messages.add('Permission denied.', 'error')
      redirect('tag')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('tag')
      return 
      
    
    #  Colorpicker JS and CSS 
    @template.set('add_css', [
      "plugins/colorpicker/css/colorpicker.css", 
      ])
    
    @template.set('add_javascript', [
      "plugins/colorpicker/js/colorpicker.js", 
      "plugins/colorpicker/js/eye.js", 
      "plugins/colorpicker/js/utils.js", 
      "plugins/colorpicker/js/layout.js", 
      "plugins/colorpicker/js/startup.js", 
      ])
    
    #  Form fields 
    $data['tag_title'] = 
      'name':'tag_title', 
      'id':'tag_title', 
      'maxlength':'15', 
      'size':'15', 
      'value':'', 
      
    $data['tag_color'] = 
      'name':'tag_color', 
      'id':'tag_color', 
      'maxlength':'6', 
      'size':'6', 
      'value':'', 
      
    $data['tag_background'] = 
      'name':'tag_background', 
      'id':'tag_background', 
      'maxlength':'6', 
      'size':'6', 
      'value':'', 
      
    
    #  Form validations 
    @validation.set_rules('tag_title', 'Tag title', 'trim|required|min_length[2]|max_length[15]|unique[tags.title]')
    @validation.set_rules('tag_color', 'Tag color', 'trim|required|exact_length[6]|is_hex')
    @validation.set_rules('tag_background', 'Background color', 'trim|required|exact_length[6]|is_hex')
    
    #  Re-populating form 
    if $_POST then 
      $data['tag_title']['value'] = @input.post('tag_title', true)
      $data['tag_color']['value'] = @input.post('tag_color', true)
      $data['tag_background']['value'] = @input.post('tag_background', true)
      
    
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'tag/add', $data)
      return 
      
    else 
      $data_tag_title = @input.post('tag_title', true)
      $data_tag_color = @input.post('tag_color', true)
      $data_tag_color = strtoupper($data_tag_color)
      $data_tag_background = @input.post('tag_background', true)
      $data_tag_background = strtoupper($data_tag_background)
      
      @db.trans_start()
      $insert_data = 
        'title':$data_tag_title, 
        'color':$data_tag_color, 
        'background':$data_tag_background, 
        
      if not @db.insert('tags', $insert_data) then 
        @db.trans_rollback()
        @messages.add('Error addding Tag - ' + $data_tag_title + '.', 'error')
        @logger.write_message("error", "Error adding tag called " + $data_tag_title)
        @template.load('template', 'tag/add', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Added Tag - ' + $data_tag_title + '.', 'success')
        @logger.write_message("success", "Added tag called " + $data_tag_title)
        redirect('tag')
        return 
        
      
    return 
    
    
  
  edit : ($id = 0) ->
    @template.set('page_title', 'Edit Tag')
    
    #  Check access 
    if not check_access('edit tag') then 
      @messages.add('Permission denied.', 'error')
      redirect('tag')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('tag')
      return 
      
    
    #  Colorpicker JS and CSS 
    @template.set('add_css', [
      "plugins/colorpicker/css/colorpicker.css", 
      ])
    
    @template.set('add_javascript', [
      "plugins/colorpicker/js/colorpicker.js", 
      "plugins/colorpicker/js/eye.js", 
      "plugins/colorpicker/js/utils.js", 
      "plugins/colorpicker/js/layout.js", 
      "plugins/colorpicker/js/startup.js", 
      ])
    
    #  Checking for valid data 
    $id = @input.xss_clean($id)
    $id = $id
    if $id < 1 then 
      @messages.add('Invalid Tag.', 'error')
      redirect('tag')
      return 
      
    
    #  Loading current group 
    @db.from('tags').where('id', $id)
    $tag_data_q = @db.get()
    if $tag_data_q.num_rows() < 1 then 
      @messages.add('Invalid Tag.', 'error')
      redirect('tag')
      return 
      
    $tag_data = $tag_data_q.row()
    
    #  Form fields 
    $data['tag_title'] = 
      'name':'tag_title', 
      'id':'tag_title', 
      'maxlength':'15', 
      'size':'15', 
      'value':$tag_data.title, 
      
    $data['tag_color'] = 
      'name':'tag_color', 
      'id':'tag_color', 
      'maxlength':'6', 
      'size':'6', 
      'value':$tag_data.color, 
      
    $data['tag_background'] = 
      'name':'tag_background', 
      'id':'tag_background', 
      'maxlength':'6', 
      'size':'6', 
      'value':$tag_data.background, 
      
    $data['tag_id'] = $id
    
    #  Form validations 
    @validation.set_rules('tag_title', 'Tag title', 'trim|required|min_length[2]|max_length[15]|uniquewithid[tags.title.' + $id + ']')
    @validation.set_rules('tag_color', 'Tag color', 'trim|required|exact_length[6]|is_hex')
    @validation.set_rules('tag_background', 'Background color', 'trim|required|exact_length[6]|is_hex')
    
    #  Re-populating form 
    if $_POST then 
      $data['tag_title']['value'] = @input.post('tag_title', true)
      $data['tag_color']['value'] = @input.post('tag_color', true)
      $data['tag_background']['value'] = @input.post('tag_background', true)
      
    
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'tag/edit', $data)
      return 
      
    else 
      $data_tag_title = @input.post('tag_title', true)
      $data_tag_color = @input.post('tag_color', true)
      $data_tag_color = strtoupper($data_tag_color)
      $data_tag_background = @input.post('tag_background', true)
      $data_tag_background = strtoupper($data_tag_background)
      
      @db.trans_start()
      $update_data = 
        'title':$data_tag_title, 
        'color':$data_tag_color, 
        'background':$data_tag_background, 
        
      if not @db.where('id', $id).update('tags', $update_data) then 
        @db.trans_rollback()
        @messages.add('Error updating Tag - ' + $data_tag_title + '.', 'error')
        @logger.write_message("error", "Error updating tag called " + $data_tag_title + " [id:" + $id + "]")
        @template.load('template', 'tag/edit', $data)
        return 
        else 
        @db.trans_complete()
        @messages.add('Updated Tag - ' + $data_tag_title + '.', 'success')
        @logger.write_message("success", "Updated tag called " + $data_tag_title + " [id:" + $id + "]")
        redirect('tag')
        return 
        
      
    return 
    
    
  
  delete : ($id) ->
    #  Check access 
    if not check_access('delete tag') then 
      @messages.add('Permission denied.', 'error')
      redirect('tag')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('tag')
      return 
      
    
    #  Checking for valid data 
    $id = @input.xss_clean($id)
    $id = $id
    if $id < 1 then 
      @messages.add('Invalid Tag.', 'error')
      redirect('tag')
      return 
      
    @db.from('tags').where('id', $id)
    $data_valid_q = @db.get()
    if $data_valid_q.num_rows() < 1 then 
      @messages.add('Invalid Tag.', 'error')
      redirect('tag')
      return 
      
    $data_tag = $data_valid_q.row()
    
    #  Deleting Tag 
    @db.trans_start()
    $update_data = 
      'tag_id':null, 
      
    if not @db.where('tag_id', $id).update('entries', $update_data) then 
      @db.trans_rollback()
      @messages.add('Error deleting Tag from Entries.', 'error')
      @logger.write_message("error", "Error deleting tag called " + $data_tag.title + " [id:" + $id + "] from entries")
      redirect('tag')
      return 
      else 
      if not @db.delete('tags', 'id':$id) then 
        @db.trans_rollback()
        @messages.add('Error deleting Tag.', 'error')
        @logger.write_message("error", "Error deleting tag called " + $data_tag.title + " [id:" + $id + "]")
        redirect('tag')
        return 
        else 
        @db.trans_complete()
        @messages.add('Tag deleted.', 'success')
        @logger.write_message("success", "Deleted tag called " + $data_tag.title + " [id:" + $id + "]")
        redirect('tag')
        return 
        
      
    return 
    
  
  
module.exports = Tag

#  End of file tag.php 
#  Location: ./system/application/controllers/tag.php 
