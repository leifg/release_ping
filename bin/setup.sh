#!/bin/sh

echo "Creating write store"
mix do event_store.create, event_store.init

echo "Creating read store"
mix ecto.create

echo "Migrating Database"
mix ecto.migrate
