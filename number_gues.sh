#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
read -p "Enter your username:" USER_NAME
#  -p prompt output the string PROMPT without a trailing newline before
#        attempting to read

username=$($PSQL "SELECT username FROM user_games WHERE username = '$USER_NAME'")

if [[ -z $username ]]
then 
  username=$USER_NAME
  ($PSQL "insert into user_games (username, games_played, best_game) values ('$username', 0, 0)")
  echo "Welcome, $username! It looks like this is your first time here." 
  best_game=0
else 
  games_played=$($PSQL "select games_played from user_games where username = '$username'")
  best_game=$($PSQL "select best_game from user_games where username = '$username'")
  echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
  fi

random_number=$[ $RANDOM % 1000 + 0 ]
count=0

echo $random_number 
read -p "Guess the secret number between 1 and 1000: " input_number
re='^[0-9]+$' #numner

while :
do
   if ! [[ $input_number =~ $re ]]; then read -p "That is not an integer, guess again: " input_number
        continue
   fi
   let "count+=1" 
   if [ $input_number -gt $random_number ]; 
    then 
      read -p "It's lower than that, guess again: " input_number
    elif [ $input_number -lt $random_number ]; 
      then  
        read -p "It's higher than that, guess again: " input_number
    elif [ $input_number -eq $random_number ]; then 
        echo "You guessed it in $count tries. The secret number was $random_number. Nice job!"
        let "games_played+=1" 
        if (($best_game==0)) || (($best_game>$count)); 
          then
            ($PSQL "update user_games set best_game=$count, games_played=$games_played where username = '$username'")
          else ($PSQL "update user_games set games_played=$games_played where username = '$username'")
        fi
        break
   fi

done

