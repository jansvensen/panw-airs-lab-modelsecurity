#!/bin/sh

# source venv/bin/activate 

# Ensures the script exits immediately if any command fails.
set -e

# Set environment variables based on the .env file
export $(grep -v '^#' .env | xargs)

# Set the model based on input parameters.
# "secure" will use a secure test model: "https://huggingface.co/amazon/chronos-t5-small"
# "insecure" will use an insecure test model: "https://huggingface.co/scthornton/chronos-t5-small-poisoned-demo"
# Any other pre-populated model can be used
case "$2" in
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
        export MODEL=$2
        ;;
esac

# Set the sacen type based on input parameters.
# "local" sets the scan to use local models.
# "hf" sets the scan to use models on huggingface.
case "$1" in
    local)
        # If the first parameter ($1) is 'local', set the scan to use local models
        export MODE="--model-path"
        export SEC=$SECURITY_GROUP_UUID_LOCAL
        ;;
    hf)
        # If the first parameter ($1) is 'hf', set the scan to use remote models
        export MODE="--model-uri"
        export SEC=$SECURITY_GROUP_UUID_HF
        ;;
esac

# Run Scan
model-security scan --security-group-uuid $SEC $MODE $MODEL

# Example local
# ./run-scan.sh local "/your/model/path"

# Example remote
# ./run-scan.sh hf "https://huggingface.co/your/model"