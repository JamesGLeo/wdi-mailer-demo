class LemurMailer < ActionMailer::Base
  default from: "no-reply@lemur.org"

  def welcome_lemur(lemur)
    sleep 5
    @lemur = lemur
    mail(to: @lemur.email, subject: "Welcome #{@lemur.name}")
  end

end
