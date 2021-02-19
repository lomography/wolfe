ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG BUNDLER_VERSION

RUN mkdir /app
WORKDIR /app

COPY Gemfile* ./
COPY wolfe.gemspec ./
COPY lib/wolfe/version.rb ./lib/wolfe/

RUN gem install bundler:$BUNDLER_VERSION
RUN bundle install -j20

COPY . ./
