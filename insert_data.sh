#!/bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# clear data from tables
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# function to insert a new winner if not already present
insert_winner() {
  local WINNER=$1
  local WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ -z $WINNER_ID ]]; then
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; then
      echo "Table [teams] - Inserted new winner: $WINNER"
    fi
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi
  echo $WINNER_ID  # return the WINNER_ID
}

# function to insert a new opponent if not already present
insert_opponent() {
  local OPPONENT=$1
  local OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ -z $OPPONENT_ID ]]; then
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; then
      echo "Table [teams] - Inserted new opponent: $OPPONENT"
    fi
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi
  echo $OPPONENT_ID  # return the OPPONENT_ID
}

# function to insert game data
insert_game() {
  local GAME_YEAR=$1
  local GAME_ROUND=$2
  local WINNER_ID=$3
  local OPPONENT_ID=$4
  local WINNER_GOALS=$5
  local OPPONENT_GOALS=$6

  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($GAME_YEAR, '$GAME_ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
    echo "Table [games] - Inserted game: $GAME_YEAR, $GAME_ROUND, Winner ID: $WINNER_ID, Opponent ID: $OPPONENT_ID, Winner Goals: $WINNER_GOALS, Opponent Goals: $OPPONENT_GOALS"
  fi
}

# read CSV and process each row
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR != "year" ]]; then
    WINNER_ID=$(insert_winner "$WINNER")
    OPPONENT_ID=$(insert_opponent "$OPPONENT")
    insert_game "$YEAR" "$ROUND" "$WINNER_ID" "$OPPONENT_ID" "$WINNER_GOALS" "$OPPONENT_GOALS"
  fi
done
