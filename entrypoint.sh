#!/bin/bash

USAGE=$(cat <<-END
    Container Usage:
    docker run -v {host-folder}:/gantree --rm -ti gantree-cli [arguments]"

    Where:
    {host-folder} = absolute path to host working folder

    Useful places to put files:
    {host-folder}/credentials/google_application_credentials.json

    {host-folder}/credentials/ssh_id_rsa_validator
    {host-folder}/credentials/ssh_id_rsa_validator.pub

    {host-folder}/config/main.config.json

END
)

GANTREE_ROOT="/gantree"
STATE_FOLDER="${GANTREE_ROOT}/state"
CONFIG_FOLDER="${GANTREE_ROOT}/config"
CRED_FOLDER="${GANTREE_ROOT}/credentials"

GCP_CREDENTIAL_NAME="google_application_credentials.json"
AWS_ACCESS_KEY_NAME="google_application_credentials"
AWS_SECRET_KEY_NAME="google_application_credentials"
DO_TOKEN_NAME="digitalocean_token"

VALIDATOR_PRIVATE_KEY_NAME="ssh_id_rsa_validator"

# check host folder mounted
if [ ! -d "/gantree" ]; then
    echo -e $USAGE
    exit 1
fi

# check sub folders
if [ ! -d "$STATE_FOLDER" ]; then
    echo -e "\nState directory not found, creating.."
    mkdir $STATE_FOLDER
    chmod 777 $STATE_FOLDER
fi

if [ ! -d "$CONFIG_FOLDER" ]; then
    echo -e "\nConfig directory not found, creating.."
    mkdir $CONFIG_FOLDER
    chmod 777 $CONFIG_FOLDER
    # TODO(ryan): create default config with gropius-cli
fi

if [ ! -d "$CRED_FOLDER" ]; then
    echo -e "\nCredentials directory not found, creating.."
    mkdir $CRED_FOLDER
    chmod 777 $CRED_FOLDER
fi

# check credentials
if [ -f "$CRED_FOLDER/$GCP_CREDENTIAL_NAME" ]; then
    GOOGLE_APPLICATION_CREDENTIALS="$CRED_FOLDER/$GCP_CREDENTIAL_NAME"
fi

if [ ! -f "$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME" ]; then
    echo -e "\nValidator ssh private key required at: {host-folder}/credentials/$VALIDATOR_PRIVATE_KEY_NAME"
    exit 1
fi

if [ -f "$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME.pub" ]; then
    echo -e "\nValidator ssh public key required at: {host-folder}/credentials/$VALIDATOR_PRIVATE_KEY_NAME.pub"
    exit 1
fi

# setup ssh
SSH_ID_RSA_VALIDATOR="$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME"
eval $(ssh-agent) &>/dev/null
ssh-add "$CRED_FOLDER/$VALIDATOR_PRIVATE_KEY_NAME"

echo -e "\n"

# run gantree-cli
gantree-cli "$@"
