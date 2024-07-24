#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  #get services, assume services will always be offered
  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services")
  #display services
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  #read selected id
  read SERVICE_ID_SELECTED
  #get service
  CHOSEN_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #if service doesn't exist, send to main menu.
  if [[ -z $CHOSEN_SERVICE_NAME ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    #ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    #get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if name doesn't exist, add to customers
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    #get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #ask for appointment time
    echo -e "\nWhat time would you like your $CHOSEN_SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    #add to appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    #print confirmation
    echo -e "\nI have put you down for a $CHOSEN_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"