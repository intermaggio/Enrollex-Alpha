require File.expand_path(File.dirname(__FILE__) + "/config/environment")
include Clockwork

handler do |job|
  case job
    when 'organization.charge'
      if Time.now.utc.day == 1 || Rails.env != 'production'
        Organization.all.each do |organization|
          if !organization.last_charge || organization.last_charge < Time.now.utc.month - 1 || Rails.env != 'production'
            Stripe.api_key = organization.stripe_secret
            end_date = Time.now.utc - Time.now.utc.mday.days + 1.month
            start_date = end_date - end_date.mday.days + 1.day
            transactions = CampersCourses.where(org_id: organization.id).within(start_date, end_date).map{|c| c.stripe_id}.uniq
            if transactions.present?
              amount = transactions.map{|id| Stripe::Charge.retrieve(id).amount}.reduce(:+) * 0.021
              Stripe.api_key =
                if Rails.env == 'production'
                  'XfaZC4N7Fprblt21L8o91wFmsr0iGnYR'
                else
                  's6f5O2kuPgMtxRDwA2cZ4RmPhCd8a4rX'
                end
              stripe = Stripe::Charge.create(
                amount: amount.round,
                currency: 'usd',
                customer: organization.card,
                description: "#{organization.name} for #{start_date.strftime("%B")}"
              )
              organization.update_attribute(:last_charge, start_date.month)
            end
          end
        end
      end
    else
      Stalker.enqueue job
  end
end

every 1.day, 'organization.charge'
