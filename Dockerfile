ARG RUBY_VERSION='3.1.1'

FROM ruby:$RUBY_VERSION

ARG BUNDLER_VERSION='2.1.4'

RUN mkdir /app
WORKDIR /app

COPY Gemfile* ./
COPY wolfe.gemspec ./
COPY lib/wolfe/version.rb ./lib/wolfe/

RUN gem install bundler:$BUNDLER_VERSION
RUN bundle install -j20

COPY . ./
