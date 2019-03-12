defmodule BinbaseBackend.Emails.Email do
  import Bamboo.Email
    
  def welcome_email(to) do
    new_email(
      to: to,
      from: "no-reply@binbase.com",
      subject: "Welcome!!!",
      html_body: "<strong>WELCOME</strong>",
      text_body: "WELCOME"
    )
    #|> put_layout({BinbaseBackendWeb.EmailView, :email})
  end
end

