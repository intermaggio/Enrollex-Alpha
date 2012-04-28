task :stripe_info => :environment do
  CampersCourses.all.each do |cc|
    Stripe.api_key = Course.find(cc.course_id).organization.stripe_secret
    cc.update_attributes(
      org_id: Course.find(cc.course_id).organization.id,
      charged_at: Time.at(Stripe::Charge.retrieve(cc.stripe_id).created.to_i)
    )
  end
end
