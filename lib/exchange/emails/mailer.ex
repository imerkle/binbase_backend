defmodule Exchange.Emails.Mailer do
    # Adds deliver_now/1 and deliver_later/1
    use Bamboo.Mailer, otp_app: :exchange
end
