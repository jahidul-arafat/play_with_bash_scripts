#!/bin/bash

source ./logger.sh
SCRIPTENTRY
updateUserDetails(){
    ENTRY
    DEBUG "Username: $1, Key: $2"
    INFO "User details updated for $1"
    EXIT
}

INFO "Updating user details..."
updateUserDetails "cubicrace" "3445"
SCRIPTEXIT