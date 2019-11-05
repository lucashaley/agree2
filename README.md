# We Agree That…

We Agree That… is an experiment in crowd-sourced axiomatic opinion.

## Heroku Deployment

This is also my first experiment in deploying to Heroku.

### My own notes:

* remember to login to Heroku in the CL by using `heroku login`
* adding an existing dir to existing project: https://stackoverflow.com/questions/5129598/how-to-link-a-folder-with-an-existing-heroku-app
* google var buildpack: https://elements.heroku.com/buildpacks/elishaterada/heroku-google-application-credentials-buildpack
* local sidekiq:
    * redis-server
    * bundle exec sidekiq
* heroku run rake db:migrate


## Some things

* Ruby version 2.4.0 for now
* Decorators? https://github.com/drapergem/draper
* https://m.patrikonrails.com/how-i-test-my-rails-applications-cf150e347a6b
* https://github.com/activeadmin/activeadmin
* https://github.com/rubocop-hq/rubocop
* https://github.com/presidentbeef/brakeman
* https://github.com/basecamp/marginalia
* https://guides.rubyonrails.org/testing.html
* https://github.com/ankane/ahoy
* https://itnext.io/sidekiq-overview-and-how-to-deploy-it-to-heroku-b8811fea9347
