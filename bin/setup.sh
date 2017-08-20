#!/bin/sh

echo "Creating write store"
mix event_store.create

echo "Creating read store"
mix ecto.create

echo "Migrating Database"
mix ecto.migrate
