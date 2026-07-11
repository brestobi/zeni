#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
  # Read .env file, ignoring comments and empty lines
  while IFS='=' read -r key value; do
    if [[ ! $key =~ ^# && -n $key ]]; then
      export "$key=$value"
    fi
  done < .env
else
  echo ".env file not found"
  exit 1
fi

# Run flutter command with variables from .env
# This avoids using the VITE_ prefix for Flutter builds.
flutter "$@" \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=$GOOGLE_SERVER_CLIENT_ID
