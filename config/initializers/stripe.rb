if Rails.env == 'production'
  Stripe.api_key = 'XzRO6WRlQySNLLsDGDiKyfu1Qy0LAepq'
else
  Stripe.api_key = 'm59zp5j6p0ZWWvzEhFf4oDZd7FRto0YC'
end
