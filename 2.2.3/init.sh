#!/bin/bash

# if any changes to Gemfile occur between runs (e.g. if you mounted the
# host directory in the container), it will install changes before proceeding
bundle check || bundle install

# Runs pending migrations if any pending
if rake db:migrate:status | grep -q '  down'; then
  rake db:migrate
fi

if [ $RAILS_ENV == "production" ]; then
  bundle exec rake assets:precompile
fi

for SCRIPT in /app/.profile.d/*;
  do source $SCRIPT;
done

exec "$@"
