#+--------------------------------------------------------------------+
#  group.coffee
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
class Group extends Controller
  
  Group :  ->
    parent::Controller()
    @load.model('Group_model')
    return 
    
  
  index :  ->
    redirect('group/add')
    return 
    
  
  add :  ->
    @load.library('validation')
    @template.set('page_title', 'New Group')
    
    #  Check access 
    if not check_access('create group') then 
      @messages.add('Permission denied.', 'error')
      redirect('account')
      return 
      
    
    #  Check for account lock 
    if @config.item('account_locked') is 1 then 
      @messages.add('Account is locked.', 'error')
      redirect('account')
      return 
      
    
    #  Form fields 
    $data['group_name'] = 
      'name':'group_name', 
      'id':'group_name', 
      'maxlength':'100', 
      'size':'40', 
      'value':'', 
      
    $data['group_parent'] = @Group_model.get_all_groups()
    $data['group_parent_active'] = 0
    $data['affects_gross'] = 0
    
    #  Form validations 
    @validation.set_rules('group_name', 'Group name', 'trim|required|min_length[2]|max_length[100]|unique[groups.name]')
    @validation.set_rules('group_parent', 'Parent group', 'trim|required|is_natural_no_zero')
    
    #  Re-populating form 
    if $_POST then 
      $data['group_name']['value'] = @input.post('group_name', true)
      $data['group_parent_active'] = @input.post('group_parent', true)
      $data['affects_gross'] = @input.post('affects_gross', true)
      
    
    if @validation.run() is false then
      @messages.add(validation_errors(), 'error')
      @template.load('template', 'group/add', $data)
      return 
      
    else 
      $data_name = @input.post('group_name', true)
      $data_parent_id = @input.post('group_parent', true)
      
      #  Check if parent group id present 
      @db.select('id').from('groups').where('id', $data_parent_id)
      if @db.get().num_rows() < 1 then 
        @messages.add('Invalid Parent group.', 'error')
        @template.load('template', 'group/add', $data)
        return 
        
      
      #  Only if Income or Expense can affect gross profit loss calculation 
      $data_affects_gross = @input.post('affects_gross', true)
      if $data_parent_id is "3" or $data_parent_id is "4" then 
        if $data_affects_gross is "1" then $data_affects_gross = 1else $data_affects_gross = 0}else 
          $data_affects_gross = 0
          @db.trans_start()$insert_data = 
          'name':$data_name, 
          'parent_id':$data_parent_id, 
          'affects_gross':$data_affects_gross, 
          if not @db.insert('groups', $insert_data) then 
          @db.trans_rollback()
          @messages.add('Error addding Group account - ' + $data_name + '.', 'error')
          @logger.write_message("error", "Error adding Group account called " + $data_name)
          @template.load('template', 'group/add', $data)
          return 
          else 
          @db.trans_complete()
          @messages.add('Added Group account - ' + $data_name + '.', 'success')
          @logger.write_message("success", "Added Group account called " + $data_name)
          redirect('account')
          return 
          }return }edit : ($id) ->
          @template.set('page_title', 'Edit Group')
          
          #  Check access 
          if not check_access('edit group') then 
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
            @messages.add('Invalid Group account.', 'error')
            redirect('account')
            return 
            
          if $id<=4 then 
            @messages.add('Cannot edit System Group account.', 'error')
            redirect('account')
            return 
            
          
          #  Loading current group 
          @db.from('groups').where('id', $id)
          $group_data_q = @db.get()
          if $group_data_q.num_rows() < 1 then 
            @messages.add('Invalid Group account.', 'error')
            redirect('account')
            return 
            
          $group_data = $group_data_q.row()
          
          #  Form fields 
          $data['group_name'] = 
            'name':'group_name', 
            'id':'group_name', 
            'maxlength':'100', 
            'size':'40', 
            'value':$group_data.name, 
            
          $data['group_parent'] = @Group_model.get_all_groups($id)
          $data['group_parent_active'] = $group_data.parent_id
          $data['group_id'] = $id
          $data['affects_gross'] = $group_data.affects_gross
          
          #  Form validations 
          @validation.set_rules('group_name', 'Group name', 'trim|required|min_length[2]|max_length[100]|uniquewithid[groups.name.' + $id + ']')
          @validation.set_rules('group_parent', 'Parent group', 'trim|required|is_natural_no_zero')
          
          #  Re-populating form 
          if $_POST then 
            $data['group_name']['value'] = @input.post('group_name', true)
            $data['group_parent_active'] = @input.post('group_parent', true)
            $data['affects_gross'] = @input.post('affects_gross', true)
            
          
          if @validation.run() is false then
            @messages.add(validation_errors(), 'error')
            @template.load('template', 'group/edit', $data)
            return 
            
          else 
            $data_name = @input.post('group_name', true)
            $data_parent_id = @input.post('group_parent', true)
            $data_id = $id
            
            #  Check if parent group id present 
            @db.select('id').from('groups').where('id', $data_parent_id)
            if @db.get().num_rows() < 1 then 
              @messages.add('Invalid Parent group.', 'error')
              @template.load('template', 'group/edit', $data)
              return 
              
            
            #  Check if parent group same as current group id 
            if $data_parent_id is $id then 
              @messages.add('Invalid Parent group', 'error')
              @template.load('template', 'group/edit', $data)
              return 
              
            
            #  Only if Income or Expense can affect gross profit loss calculation 
            $data_affects_gross = @input.post('affects_gross', true)
            if $data_parent_id is "3" or $data_parent_id is "4" then 
              if $data_affects_gross is "1" then $data_affects_gross = 1else $data_affects_gross = 0}else 
                $data_affects_gross = 0
                @db.trans_start()$update_data = 
                'name':$data_name, 
                'parent_id':$data_parent_id, 
                'affects_gross':$data_affects_gross, 
                if not @db.where('id', $data_id).update('groups', $update_data) then 
                @db.trans_rollback()
                @messages.add('Error updating Group account - ' + $data_name + '.', 'error')
                @logger.write_message("error", "Error updating Group account called " + $data_name + " [id:" + $data_id + "]")
                @template.load('template', 'group/edit', $data)
                return 
                else 
                @db.trans_complete()
                @messages.add('Updated Group account - ' + $data_name + '.', 'success')
                @logger.write_message("success", "Updated Group account called " + $data_name + " [id:" + $data_id + "]")
                redirect('account')
                return 
                }return }delete : ($id) ->
                #  Check access 
                if not check_access('delete group') then 
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
                  @messages.add('Invalid Group account.', 'error')
                  redirect('account')
                  return 
                  
                if $id<=4 then 
                  @messages.add('Cannot delete System Group account.', 'error')
                  redirect('account')
                  return 
                  
                @db.from('groups').where('parent_id', $id)
                if @db.get().num_rows() > 0 then 
                  @messages.add('Cannot delete non-empty Group account.', 'error')
                  redirect('account')
                  return 
                  
                @db.from('ledgers').where('group_id', $id)
                if @db.get().num_rows() > 0 then 
                  @messages.add('Cannot delete non-empty Group account.', 'error')
                  redirect('account')
                  return 
                  
                
                #  Get the group details 
                @db.from('groups').where('id', $id)
                $group_q = @db.get()
                if $group_q.num_rows() < 1 then 
                  @messages.add('Invalid Group account.', 'error')
                  redirect('account')
                  return 
                  else 
                  $group_data = $group_q.row()
                  
                
                #  Deleting group 
                @db.trans_start()
                if not @db.delete('groups', 'id':$id) then 
                  @db.trans_rollback()
                  @messages.add('Error deleting Group account - ' + $group_data.name + '.', 'error')
                  @logger.write_message("error", "Error deleting Group account called " + $group_data.name + " [id:" + $id + "]")
                  redirect('account')
                  return 
                  else 
                  @db.trans_complete()
                  @messages.add('Deleted Group account - ' + $group_data.name + '.', 'success')
                  @logger.write_message("success", "Deleted Group account called " + $group_data.name + " [id:" + $id + "]")
                  redirect('account')
                  return 
                  
                return 
                }#  End of file group.php #  Location: ./system/application/controllers/group.php 
module.exports = Group