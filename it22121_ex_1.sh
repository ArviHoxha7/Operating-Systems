#!/bin/bash

#checking if parameter is given 
if [ "$#" -ne 1 ]; then
    echo "Enter like this: $0 [easy, medium, hard]"
    exit 1
fi

# Define the value for each level of difficulty
EASY_CHARS='a-zA-Z0-9'
MEDIUM_CHARS='a-zA-Z0-9.!\#'
HARD_CHARS='a-zA-Z0-9.!\#@,?^\$'

case $1 in
    easy)
        LENGTH=8
        CHARS=$EASY_CHARS
        ;;
    medium)
        LENGTH=12
        CHARS=$MEDIUM_CHARS
        ;;
    hard)
        LENGTH=20
        CHARS=$HARD_CHARS
        ;;
    *)
        echo "Invalid input: $1"
        exit 1
        ;;
esac

PASSWORD=$(< /dev/urandom tr -dc "$CHARS" | head -c$LENGTH)

echo "The password is: $PASSWORD"

