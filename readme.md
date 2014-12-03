# ActionMailer and Sidekiq

ActionMailer allows us to send emails from our Rails applications.  They are really just another way of renering views.  But instead of delivering through the HTTP protocol, we are delivering them via email protocols.

## 0. Generate models / views / controllers
```bash
rails g scaffold lemur name email  && rake db:create && rake db:migrate
```

```ruby
# routes.rb
Rails.application.routes.draw do
  resources :lemurs
  root to: "lemurs#index"
end
```

## 1. Generate a mailer

```bash
bin/rails g mailer LemurMailer
```

This generates a file and a folder for us:

```
create  app/mailers/lemur_mailer.rb
invoke  erb
create  app/views/,lemur_mailer
```

`user_mailer.rb` defines a LemurMailer class that inherits from [ActionMailer::Base](http://api.rubyonrails.org/classes/ActionMailer/Base.html).


`app/views/lemur_mailer` is a directory wherein we can define templates that our mailer will use.  Mailers are not altogether different from controllers insofar as each method defined within a mailer is mapped to a corresponding view located in a `[CLASSNAME]_mailer` directory.

# 2. Define mailer behavior

We will send a welcome message when a user sign's up for our service.  (For the purpose of this email)


```ruby
#lemur_mailer.rb
class LemurMailer < ActionMailer::Base
  default from: "no-reply@lemur.org"

  def welcome_lemur(lemur)
    @lemur = lemur
    mail(to: @lemur.email, subject: "Welcome, Lemur #{@lemur.name}")
  end
  end
  ```

  # 3. Build views

  We will build both html and plain text versions of our views as not all email clients can handle html.  ActionMailer will detect both and automatically generate a [`multipart/alternative`](http://stackoverflow.com/questions/8320141/multipart-alternative-subtype-when-client-use-it) email.


  # 4.  Call mailer in controller

  We should send our welcome message when a lemur signs up, right?

  ```ruby
  #lemurs_controller.rb
  def create
  @lemur = Lemur.new(lemur_params)

  respond_to do |format|
  if @lemur.save

  LemurMailer.welcome_lemur(@lemur).deliver

  format.html { redirect_to @lemur, notice: 'Lemur was successfully created.' }
  format.json { render :show, status: :created, location: @lemur }
  else
  format.html { render :new }
  format.json { render json: @lemur.errors, status: :unprocessable_entity }
  end
  end
  end
  ```

  #5. MailCatcher

  Sadly, things don't work because we haven't configured an SMTP server.   **WHAT NOW?**

  We could connect our development environment to an actual SMTP server, but then we would run the risk of sending actual emails.  This is not the best idea when we are still developing the application.
  Enter [mailcatcher](http://mailcatcher.me/).  MailCatcher is a RubyGem that runs a lightweight SMTP server.  Any email sent to this server will be captured and not sent out.  But we will have the luxury of being able to see the emails at `localhost:1080`


  ###Install MailCatcher

  #####1) Install the gem

  But do not include it in your Gemfile.  This could cause dependency issues with our Rails application.

  ```bash
  gem install mailcatcher
  ```

  #####2) Configure
  ```ruby
  #environments/development.rb
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }

  ```

  #####3) Run!
  MailCatcher runs as a daemon by default.  In order to stop the process, We can quit through the web interface.s

  ```bash
  mailcatcher
  ```

  #6.  Sidekiq

  One of the most common use cases for background jobs is the sending of e-mails.  What if it takes time to send an email? (i.e. there is a call to `sleep`)  We shouldn't wait to render html to our users.

  ###Make sure redis is installed

  [Redis](http://redis.io/) is just a big key value store running on a server.  You can think of it as a lightweight, non-relational database.

  ```bash
  brew install redis
  ```
  ###Add sidekiq to Gemfile


  ```ruby
  #Gemfile
  gem 'sidekiq'
  ```

  ###Modify controller

  ```ruby
  LemurMailer.delay.welcome_lemur(@lemur)
  ```
  ***Note:***
  * We no longer have to call `deliver`.
  * Sidekiq supports sending emails asynchronously out of the box.  It does so by adding three methods to `ActionMailer`, `delay`, `delay_for`, `delay_until`.


  ###Run sidekiq

  From your application root:
  ```bash
  bundle exec sidekiq
  ```

  And it just works...

  #7.  Deploying to a remote server

  We need to set up an SMTP(Simple Mail Transfer Protocol) server in order to send (and receive) email from our application.

  We have several options on heroku.  Check out:

  * SendGrid
  * Mandrill by MailChimp
  * MailGun

  In the spirit of Serial / Lemurs, we will go with MailChimp's product, Mandrill.

  ##Setup add on
  ```bash
  heroku addons:add mandrill:starter
  ```

  This does a bunch of things, including defining some environmental variables..

  ```bash
  heroku config:get MANDRILL_APIKEY
  ```

  ##Configure Mandrill

  ```ruby
  #production.rb

  ActionMailer::Base.smtp_settings = {
    port: '587',
    address: 'smtp.mandrillapp.com',
    user_name: ENV['MANDRILL_USERNAME'],
    password:  ENV['MANDRILL_APIKEY'],
    domain:    'heroku.com',
    authentication: :plain
  }
  ActionMailer::Base.delivery_method = :smtp


  ```

  ##Getting sidekiq to work on Heroku

  ###Create Procfile
  ```bash
  #Procfile
  worker: bundle exec sidekiq
  ```
  ###Add redis-to-go

  ```bash
  heroku addons:add redistogo
  ```
  ###Spin up worker

  ```bash
  heroku ps:scale worker+1
  ```

  # *~*~*~FIN~*~*~*


  ***Note:*** Scale your worked back down to 0 or you may get charged.
  ```bash
  heroku ps:scale worker-1
  ```

  # Resources

  * http://mailcatcher.me/

  * https://github.com/mperham/sidekiq/wiki/Deployment

  * http://blog.remarkablelabs.com/2013/01/using-sidekiq-to-send-emails-asynchronously

  * https://mandrill.com/

