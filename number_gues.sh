#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USER_NAME

username=$($PSQL "SELECT username FROM user_games WHERE username = '$USER_NAME'")

if [[ -z $username ]] 
  then
    echo "Welcome, $USER_NAME! It looks like this is your first time here." 
    insert=$($PSQL "insert into user_games (username, games_played, best_game) values ('$USER_NAME', 0, 0)")
    games_played=0
    best_game=0
  else
    games_played=$($PSQL "SELECT games_played FROM user_games WHERE username = '$USER_NAME'")
    best_game=$($PSQL "SELECT best_game FROM user_games WHERE username = '$USER_NAME'")
    echo "Welcome back, $USER_NAME! You have played $games_played games, and your best game took $best_game guesses."
fi

RAN_NUM=$[ $RANDOM % 1000 + 0 ]

# echo $RAN_NUM 

echo "Guess the secret number between 1 and 1000:"

GUESS=1
while read input_number
do
  # GUESS=$((GUESS+1))
  if  [[ $input_number =~ ^[0-9]+$ ]];
    then 
      GUESS=$((GUESS+1))
    if [ $input_number -eq $RAN_NUM ];
      then
        let "games_played+=1"   
        echo "You guessed it in $((GUESS-1)) tries. The secret number was $RAN_NUM. Nice job!"
        break;
      else
        if [ $input_number -lt $RAN_NUM ];
          then
            echo "It's higher than that, guess again:" 
        elif [ $input_number -gt $RAN_NUM ];
          then
             echo "It's lower than that, guess again:" 
        fi
    fi
    else
        echo "That is not an integer, guess again:" 
  fi
done

if (($best_game==0)) || (($best_game>$GUESS)); 
  then
   ($PSQL "update user_games set best_game=$GUESS, games_played=$games_played where username = '$USER_NAME'")
  else 
    ($PSQL "update user_games set games_played=$games_played where username = '$USER_NAME'")
fi    
