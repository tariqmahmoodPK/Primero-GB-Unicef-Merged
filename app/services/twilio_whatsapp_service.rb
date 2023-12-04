require 'twilio-ruby'

class TwilioWhatsappService
  def initialize
    account_sid = Rails.application.credentials.dig(:TWILIO_ACCOUNT_SID)
    auth_token = Rails.application.credentials.dig(:TWILIO_AUTH_TOKEN)
    @client = Twilio::REST::Client.new(account_sid, auth_token)
    myLogger = Logger.new(STDOUT)
    myLogger.level = Logger::DEBUG
    @client.logger = myLogger
  end

  def send_whatsapp_message(to, body)
    message = @client.messages.create(
      from: "whatsapp:+14155238886",
      body: body,
      to: "whatsapp:#{to}"
    )

    puts "Message sent with SID: #{message.sid}"
  end
end
