#!/bin/bash

if [ $RAILS_ENV == "production" ]; then
  bundle exec rake assets:precompile
fi

for SCRIPT in /app/.profile.d/*;
  do source $SCRIPT;
done

exec "$@"
