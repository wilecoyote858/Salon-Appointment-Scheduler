#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) CLIENT_MENU ;;
        *) SERVICES_MENU "I could not find that service. What would you like today?\n" ;;
  esac
}

CLIENT_MENU() {
  # get customer info 
  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # if customer does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "I don't have a record for that phone number, what's your name?\n"
    read CUSTOMER_NAME
  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?\n"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi


}

SERVICES_MENU
