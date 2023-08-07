FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y default-mysql-client

WORKDIR /my-app

COPY Gemfile /my-app/Gemfile
COPY Gemfile.lock /my-app/Gemfile.lock

RUN bundle install

EXPOSE 3000

COPY . /my-app

CMD ["rails", "server", "-b", "0.0.0.0"]
