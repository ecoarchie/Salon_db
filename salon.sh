#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  #display list of services
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if such service id doesn't exist
  if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
  then
    MAIN_MENU
  else
    echo -e "\nPlease enter your phone"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer's name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      #insert customer's name, phone into customers
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    # get customer's ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get the time for appointment
    echo -e "\nAt what time do you want to make an appointment?"
    read SERVICE_TIME

    # insert data into appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE_ID_SELECTED_RESULT | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}



MAIN_MENU