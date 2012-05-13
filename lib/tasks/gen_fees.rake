task :gen_fees => :environment do
  OrgCharge.destroy_all
  Organization.all.each do |organization|
    Stripe.api_key = 'tbRPrJWI1ZLEdH07M4TPAPjpvxCVyhwi'
    transactions = CampersCourses.where(org_id: organization.id).map{|c| { stripe_id: c.stripe_id, course_id: c.course_id, charged_at: c.charged_at }}.uniq
    if transactions.present?
      transactions.each{ |transaction|
        amount = Stripe::Charge.retrieve(transaction[:stripe_id]).amount * 0.021
        organization.org_charges.create(stripe_id: transaction[:stripe_id], course_id: transaction[:course_id], charged_at: transaction[:charged_at], amount: amount)
      }
    end
  end
end
