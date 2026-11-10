ARG RUBY_VERSION=4.0.4
FROM ruby:${RUBY_VERSION}

WORKDIR /app

COPY Gemfile Gemfile.lock wolfe.gemspec ./
COPY lib/wolfe/version.rb ./lib/wolfe/
RUN bundle install

COPY . ./

CMD ["bundle", "exec", "rake", "test"]
