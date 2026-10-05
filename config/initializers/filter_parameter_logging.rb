# Keep sensitive values out of the logs, e.g. passwords submitted on sign in and sign up.
Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
]
