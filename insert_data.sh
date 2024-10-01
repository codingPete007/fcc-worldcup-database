#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TEAMS=("placeholder team")

check_unique() {
  local new_team="$1"

  for team in "${TEAMS[@]}" 
  do
    if [[ "$new_team" == "$team" ]]
    then
      return 1
    fi
  done

  TEAMS+=("$new_team")
  return 0
}

sed '1d' "games.csv" | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if check_unique "$WINNER"
  then
    echo "Team $WINNER added to the databank"
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
  else
    echo "Team $WINNER already exists"
  fi

  if check_unique "$OPPONENT"
  then
    echo "Team $OPPONENT added to the databank"
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
  else
    echo "Team $OPPONENT already exists"
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done