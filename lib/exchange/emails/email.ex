defmodule Exchange.Emails.Email do
  import Bamboo.Email

  def welcome_email(to) do
    new_email(
      to: to,
      from: "no-reply@exchange.com",
      subject: "Welcome!!!",
      html_body: "<strong>WELCOME</strong>",
      text_body: "WELCOME"
    )
    #|> put_layout({ExchangeWeb.EmailView, :email})
  end
end

