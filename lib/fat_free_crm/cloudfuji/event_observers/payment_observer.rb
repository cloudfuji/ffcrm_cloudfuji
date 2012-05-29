module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class PaymentObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base

      end
    end
  end
end
