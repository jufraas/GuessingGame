#!/bin/bash

DB_HOST="localhost"
DB_PORT=5432
DB_NAME="guessing_game"
DB_USER="postgres"
DB_DB_PASSWORD="password"
SCHEMA_NAME="public"
TABLE_PLAYER="player"
TABLE_PUNTUACTION="punctuation"

# welcome
echo "welcome to the guessing game"
echo "Try to guess the secret number 1 and 100"

read -p "Enter you name: " player_name

player_id=$(psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -t -c "SELECT player_id FROM $SCHEMA_NAME.$TABLE_PLAYER WHERE name = '$PLAYER_NAME';")

if [ -z "$player_id" ]; then
  # Player doesn't exist, insert a new player
  player_id=$(psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -t -c "INSERT INTO $SCHEMA_NAME.$TABLE_PLAYER (name) VALUES ('$PLAYER_NAME') RETURNING player_id;")
fi

attempts=0
guess=0

secret_number=$(( (RANDOM % 100) + 1 ))


#This code snippet creates a loop that will continue to prompt the user to guess a secret number until they enter a valid number. If the user enters something that is not an integer, they are prompted to enter a valid number before continuing.
while [ $guess -ne $secret_number ]; do
  read -p "Enter your guess: " guess

  # Validate if the input is a number
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    continue
  fi
  attempts=$((attempts + 1))

  if [ $guess -lt $secret_number ]; then
    echo "The secret number is higher."
  elif [ $guess -gt $secret_number ]; then
    echo "The secret number is lower."
  fi
done

# Calculate the score based on the number of attempts
if [ $attempts -le 5 ]; then
  score=100
elif [ $attempts -le 10 ]; then
  score=80
elif [ $attempts -le 15 ]; then
  score=60
elif [ $attempts -le 20 ]; then
  score=40
elif [ $attempts -le 25 ]; then
  score=10
else
  score=0
fi

current_date=$(date +"%Y-%m-%d %H:%M:%S")
psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -c "INSERT INTO $SCHEMA_NAME.$TABLE_PUNTUACTION (date, player_id, punctuation) VALUES ('$current_date', $player_id, $score);"

echo "Congratulations, $PLAYER_NAME! You guessed the secret number ($secret_number) in $attempts attempts."
echo "Your score is: $score points."

# Show the top scores
echo "Top Scores:"
psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -c "SELECT $SCHEMA_NAME.$TABLE_PLAYER.name, $SCHEMA_NAME.$TABLE_PUNTACTION.punctuation, $SCHEMA_NAME.$TABLE_PUNTACTION.date FROM $SCHEMA_NAME.$TABLE_PUNTACTION JOIN $SCHEMA_NAME.$TABLE_PLAYER ON $SCHEMA_NAME.$TABLE_PUNTACTION.player_id = $SCHEMA_NAME.$TABLE_PLAYER.player_id ORDER BY $SCHEMA_NAME.$TABLE_PUNTACTION.punctuation ASC LIMIT 10;"
