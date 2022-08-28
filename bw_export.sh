#!/bin/bash

# Bitwarden CLI Vault Export Script
# Author: David H (@dh024)
#  
# This script will backup the following:
#   - personal vault contents, password encrypted (or unencrypted)
#   - organizational vault contents (passwd encrypted or unencrypted)
#   - file attachments
# It will also report on whether there were items in the Trash that
# could not be exported.


#Set Bitwarden login name (email address)
user_email="<INSERT YOUR BITWARDEN LOGIN EMAIL HERE>"
#EXAMPLE:
#user_email="dh024@domain.com"  

#Set locations to save export files
save_folder="<INSERT THE PATH TO YOUR SAVE FOLDER HERE AND END WITH A FORWARD SLASH>"
#EXAMPLE:
#save_folder="$HOME/Documents/Bitwarden_Export/"

save_folder_attachments="<INSERT THE PATH TO YOUR SAVE FOLDER HERE AND END WITH A FORWARD SLASH>"
#EXAMPLE:
#save_folder_attachments="$HOME/Temp/Attachments/"

#Set Organization ID (if applicable)
org_id="<INSERT YOUR ORGANIZATION_ID HERE>"
#EXAMPLE:   
#org_id="cada13d7-5418-37ed-981b-be822121c593"   
#   To obtain your organization_id value, open a terminal and type:
#   bw login #(follow the prompts); bw list organizations | jq -r '.[0] | .id'


echo "Starting export script..."

#Prompt user for their Bitwarden password
echo -n "Enter your Bitwarden password: "
read -s bw_password
echo 

#Login user if not already authenticated
if [[ $(bw status | jq -r .status) == "unauthenticated" ]]
then 
    echo "Performing login..."
    bw login $user_email $bw_password --method 0 --quiet
fi
if [[ $(bw status | jq -r .status) == "unauthenticated" ]]
then 
    echo "ERROR: Failed to authenticate."
    echo
    exit 1
fi

#Unlock the vault
session_key=$(bw unlock $bw_password --raw)

#Verify that unlock succeeded
if [[ $session_key == "" ]]
then 
    echo "ERROR: Failed to authenticate."
    echo
    exit 1
else
    echo "Login successful."
    echo
fi

#Export the session key as an env variable (needed by BW CLI)
export BW_SESSION="$session_key" 


#Prompt the user for an encryption password
echo -n "Enter a password to encrypt your vault (or press ENTER for an unencrypted export): "
read -s password1
echo

#Check if the user has decided to enter a password or save unencrypted
if [[ $password1 == "" ]]
then 
    echo -e -n "\033[0;33m" # set text = yellow
    echo "WARNING! Your vault contents will be saved to an unencrypted file."     
    echo -e -n "\033[0m" # set text = default color

    until [[ $CONTINUE =~ (y|n) ]]
    do
        read -rp "Continue? [y/n]: " -e CONTINUE
    done

    if [[ $CONTINUE == "n" ]]
    then
        echo "Exiting script."
        echo
        exit 1
    fi
else
    echo -n "Enter the same password for verification: "
    read -s password2
    echo
    
    if [[ $password1 != $password2 ]]
    then
        echo "ERROR: The passwords did not match."
        echo
        exit 1
    else
        echo "Password verified. Be sure to save your password in a safe place!"
        echo
    fi
fi


echo "Performing vault exports..."

# 1. Export the personal vault 
if [[ ! -d "$save_folder" ]]
then
    echo "ERROR: Could not find the folder in which to save the files."
    echo
    exit 1
fi

if [[ $password1 == "" ]]
then
    echo
    echo "Exporting personal vault to an unencrypted file..."
    bw export --format json --output $save_folder
else
    echo 
    echo "Exporting personal vault to a password-encrypted file..."
    bw export --format encrypted_json --password $password1 --output $save_folder
fi


# 2. Export the organization vault (if specified) 
if [[ ! -z "$org_id" ]]
then 
    if [[ $password1 == "" ]]
    then
        echo
        echo "Exporting organization vault to an unencrypted file..."
        bw export --organizationid $org_id --format json --output $save_folder
    else
        echo 
        echo "Exporting organization vault to a password-encrypted file..."
        bw export --organizationid $org_id --format encrypted_json --password $password1 --output $save_folderP@ssR3
    fi
else
    echo
    echo "No organizational vault exists, so nothing to export."
fi


# 3. Download all attachments (file backup)
#First download attachments in vault
if [[ $(bw list items | jq -r '.[] | select(.attachments != null)') != "" ]]
then
    echo
    echo "Saving attachments..."
    bash <(bw list items | jq -r '.[] 
    | select(.attachments != null) 
    | "bw get attachment \"\(.attachments[].fileName)\" --itemid \(.id) --output \"'$save_folder_attachments'\(.name)/\""' )
else
    echo
    echo "No attachments exist, so nothing to export."
fi 

echo
echo "Vault export complete."


# 4. Report items in the Trash (cannot be exported)
trash_count=$(bw list items --trash | jq -r '. | length')

if [[ $trash_count > 0 ]]
then
    echo -e -n "\033[0;33m" # set text = yellow
    echo "Note: You have $trash_count items in the trash that cannot be exported."
    echo -e -n "\033[0m" # set text = default color
fi


echo
bw lock 
echo
