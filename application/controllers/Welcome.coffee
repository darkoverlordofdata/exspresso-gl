#+--------------------------------------------------------------------+
#  welcome.coffee
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

module.exports = class Welcome extends system.core.Controller

  step = require('step')

  Welcome :  ->
    super

  
  indexAction :  ->
    @load.model('Ledger_model')
    @load.library('accountlist')
    @template.set('page_title', 'Welcome to Webzash')
    
    #  Bank and Cash Ledger accounts 
    @db.from('ledgers').where('type', 1)

    $this = @
    step(
      () ->
        $this.db.get @

      ,($err, $bank_q) ->
        throw $err if $err?
        $group = @group()

        $bank_q.result().forEach ($row) ->
          $this.ledger_model.get_ledger_balance $row.id, $group()


      ,($err, $ledgers) ->
        throw $err if $err?
        $data = {}
        $data['bank_cash_account'] = []
        for $row in $ledgers
          $data['bank_cash_account'].push
            id      :$row.id
            name    :$row.name
            balance :$row.balance

        #  Calculating total of Assets, Liabilities, Incomes, Expenses
        $asset = new Accountlist()
        $asset.init(1)
        $data['asset_total'] = $asset.total

        $liability = new Accountlist()
        $liability.init(2)
        $data['liability_total'] = $liability.total

        $income = new Accountlist()
        $income.init(3)
        $data['income_total'] = $income.total

        $expense = new Accountlist()
        $expense.init(4)
        $data['expense_total'] = $expense.total

        #  Getting Log Messages
        $data['logs'] = $this.logger.read_recent_messages()
        $this.template.load 'template', 'welcome', $data

    )


module.exports = Welcome

#  End of file Welcome.coffee
#  Location: ./application/controllers/Welcome.coffee
