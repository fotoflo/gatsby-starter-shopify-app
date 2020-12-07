#!/bin/bash
# first source your env
if [ -z "$FIREBASE_PROJECT_ID" ]
then
    echo "source your env"
    exit 0
else 
    parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
    echo "creating config at $parent_path/.runtimeconfig.json"
fi

#firebase functions:config:unset var

firebase functions:config:set \
fire.app_project_id="$FIREBASE_PROJECT_ID" \
fire.client_email="$FIREBASE_CLIENT_EMAIL" \
fire.private_key="$FIREBASE_PRIVATE_KEY"   \
shopify.app_api_key="$SHOPIFY_APP_API_KEY" \
shopify.app_shared_secret="$SHOPIFY_APP_API_SECRET" \
shopify.app_url="$SHOPIFY_APP_URL"   \
shopify.app_name_url="$SHOPIFY_APP_NAME_URL" \
shopify.app_scopes="$SHOPIFY_APP_SCOPES" \
ngrok.domain="$NGROK_DOMAIN" \

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

firebase functions:config:get > .runtimeconfig.json