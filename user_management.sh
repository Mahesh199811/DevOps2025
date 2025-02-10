#!/bin/bash

<<Note 
Account Creation
1. Implement an option -c or --create that allows the script to create a new user account. The script should prompt the user to enter the new username and password.
2. Ensure that the script checks whether the username is available before creating the account. If the username already exists, display an appropriate message and exit gracefully.
3. After creating the account, display a success message with the newly created username.
Note

# Function to display help information
function show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c, --create    Create a new user account"
    echo "  -d, --delete    Delete an existing user account"
    echo "  -r, --reset     Reset the password of an existing user account"
    echo "  -l, --list      List all user accounts"
    echo "  -h, --help      Display this help message"
}

# Function to create a new user account
function create_user() {
    read -p "Enter new username: " username
    if id "$username" &>/dev/null; then
        echo "Error: User '$username' already exists."
        exit 1
    fi
    read -sp "Enter password for $username: " password
    echo
    sudo useradd -m -p "$(openssl passwd -1 "$password")" "$username"
    echo "User '$username' created successfully."
}

# Function to delete an existing user account
function delete_user() {
    read -p "Enter username to delete: " username
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        exit 1
    fi
    sudo userdel -r "$username"
    echo "User '$username' deleted successfully."
}

# Function to reset the password of an existing user account
function reset_password() {
    read -p "Enter username to reset password: " username
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        exit 1
    fi
    read -sp "Enter new password for $username: " password
    echo
    echo "$username:$(openssl passwd -1 "$password")" | sudo chpasswd
    echo "Password for user '$username' reset successfully."
}

# Function to list all user accounts
function list_users() {
    echo "User accounts on the system:"
    awk -F: '{ print $1, $3 }' /etc/passwd
}

# Main script logic
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

case "$1" in
    -c|--create)
        create_user
        ;;
    -d|--delete)
        delete_user
        ;;
    -r|--reset)
        reset_password
        ;;
    -l|--list)
        list_users
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        exit 1
        ;;
esac
