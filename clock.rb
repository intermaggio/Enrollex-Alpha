require File.expand_path(File.dirname(__FILE__) + "/config/environment")
include Clockwork

handler do |job|
  case job
    when 'organization.charge'
      if Time.now.utc.day == 1 || Rails.env != 'production'
        Organization.all.each do |organization|
          if !organization.last_charge || organization.last_charge < Time.now.utc.month - 1
            Stripe.api_key = organization.stripe_secret
            end_date = Time.now.utc - Time.now.utc.mday.days
            start_date = end_date - 1.month + 1.day
            transactions = CampersCourses.where(org_id: organization.id).within(start_date, end_date).map{|c| Stripe::Charge.retrieve(c.stripe_id).amount}
            if transactions.present?
              amount = transactions.reduce(:+) * 0.021
              Stripe.api_key =
                if Rails.env == 'production'
                  'XfaZC4N7Fprblt21L8o91wFmsr0iGnYR'
                else
                  's6f5O2kuPgMtxRDwA2cZ4RmPhCd8a4rX'
                end
              stripe = Stripe::Charge.create(
                amount: amount.to_i,
                currency: 'usd',
                customer: organization.card,
                description: "#{organization.name} for #{(Time.now.utc - 1.day).strftime("%B")}"
              )
              organization.update_attribute(:last_charge, (Time.now.utc - 1.day).month)
            end
          end
        end
      end
    else
      Stalker.enqueue job
  end
end

every 1.day, 'organization.charge'
