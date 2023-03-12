class NotifierMailer < ApplicationMailer
  def notify_email(email)
    @idea = params[:idea]
    mail(to: email, subject: 'An idea coming!')
  end
end
