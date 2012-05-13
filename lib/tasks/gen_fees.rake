task :gen_fees => :environment do
  Organization.all.each do |organization|
    Stripe.api_key = organization.stripe_secret
    transactions = CampersCourses.where(org_id: organization.id).map{|c| c.stripe_id}.uniq
    if transactions.present?
      transactions.each{ |id|
        amount = Stripe::Charge.retrieve(id).amount * 0.021
        organization.org_charges.create(stripe_id: id, amount: amount)
      }
    end
  end
end
