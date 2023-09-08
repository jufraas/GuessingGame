#!/bin/bash
DB_USER="postgres"
DB_NAME="guessing_game" 

# Request data from the user
read -p "What is your name: " name

# query to insert the data
insert_query="INSERT INTO public.player (name) VALUES ('$name');"

#run query
psql -U $DB_USER -d $DB_NAME -c "$insert_query"
