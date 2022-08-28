# Bitwarden_Export
Bash script that exports your Bitwarden vault contents

## Description
This simple bash script uses the Bitwarden CLI to perform three backup tasks:
* export personal vault
* export organization vault (if applicable)
* export file attachments (if applicable)

The script provides the choice of creating unencrypted export files or password-encrypted export files. Attachments are not encrypted.

### Disclaimer
I wrote this bash script pretty quickly and have not thoroughly tested it, so use at your own peril! 

Since the purpse of this script is to create a copy of all your passwords and secrets stored in Bitwarden, you should carefully inspect this script to ensure it meets your needs and that it will execute as you would expect. I provide no guarantees that it will work for you!

### Compatibility
This script was written for the Bash 3.2 shell on MacOS, but it should run just fine on any machine that has a bash shell installed. For example, on Windows PCs, the script should run fine using the Windows Subsystem for Linux (WSL). However, I have not tested the script outside of MacOS, so use at your own risk.

## Requirements
This script requires the following:
* **Bash shell** (tested on Bash version 3.2; should work fine on any more recent version)
* **Bitwarden CLI** software must be installed (see: https://bitwarden.com/help/cli/)
* **jq** must be installed and available to your shell (see: https://github.com/stedolan/jq/); available on most package managers

## How to Use the Script
Before you use the script for the first time, you must edit the variables in lines 14 - 25 of the script to provide the folder locations to save your export files and attachments, as well as your organization ID (if you want to export your organization vault; just leave it blank otherwise). Ensure that you **end each folder name with a forward-slash** or the script may fail or produce unanticipated results.

The script will prompt you for your password each time so that you don't have to save that within the script.

### Execution:
From a terminal window, simply type: `bash bw_export.sh` and follow the prompts. 

## Outputs
The following are created by the script:
* JSON file containing your exported personal vault contents (password-encryption is recommended)
* JSON file containing your exported organization vault contents (optional)
* folder containing copies of your file attachments, labelled by subfolder names that match the name given to each vault item

## Special Notes
Before you use this script, please consider the following:
* the script is meant to be run interactively, so it is not suitable for automation (e.g., execution as a scheduled script, such as a cron job)
* sensitive information, such as your password and session keys, are not saved locally or to persistent environment variables for security reasons
* if you choose to use password-encryption to store your export files (recommended) be sure that you use a strong and memorable password! (don't just store it inside Bitwarden, because if you get locked out of your account you won't be able to restore your exports)
* the script is currently limited to export just one organization vault, so if you have two or more organization vaults in your account, only the first will be exported (I may extend the script in the future to accommodate multiple organization vaults)
* if you don't know your `organization id` value, just open a terminal window and type: `bw login; bw list organizations | jq -r '.[0] | .id'`
* note: the script will **not** export vault items in your Trash, nor will it export your password history -- this is a limitation of the Bitwarden CLI tools
* if you spot an issue with the script and/or want to suggest a change, feel free to reach out
