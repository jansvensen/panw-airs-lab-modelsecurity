#!/bin/sh
# Ensures the script exits immediately if any command fails.
set -e

# Set environment variables based on the .env file
export $(grep -v '^#' .env | xargs)

# Set the model based on input parameters.
# "secure" will use a secure test model: "https://huggingface.co/amazon/chronos-t5-small"
# "insecure" will use an insecure test model: "https://huggingface.co/scthornton/chronos-t5-small-poisoned-demo"
# Any other pre-populated model can be used
case "$1" in
    secure)
        # If the first parameter ($1) is 'secure', set the model to be the secure model
        export MODEL="https://huggingface.co/amazon/chronos-t5-small"
        ;;
    insecure)
        # If the first parameter ($1) is 'insecure', set the model to be the insecure model
        export MODEL="https://huggingface.co/scthornton/chronos-t5-small-poisoned-demo"
        ;;
    *)
        # If the first parameter ($1) is anything else, set the model to be given one
        export MODEL=$1
        ;;
esac

# Run Scan
model-security scan --security-group-uuid $SECURITY_GROUP_UUID --model-uri $MODEL