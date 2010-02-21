ActionController::Dispatcher.to_prepare(:billing) do
  Billing.klass = :krus
  Billing.host = 'pay.orbitel.ru'
  Billing.port = 3100
  Billing.key  = 'AucKeacBorjyoHic'
end
