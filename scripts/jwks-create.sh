#!/bin/sh
set -e

echo "Creating ES256 JWKs in realm: $REALM_NAME"
echo "Hydra admin endpoint: $HYDRA_ADMIN_SERVICE_PATH"

ACCESS_TOKEN_JWK=$(hydra get jwk hydra.jwt.access-token --endpoint $HYDRA_ADMIN_SERVICE_PATH 2>&1 || true)

echo "🔑 Creating new ES256 access token key (hydra.jwt.access-token)..."
if echo "$ACCESS_TOKEN_JWK" | grep -q '"error": "Not Found"' || ! echo "$ACCESS_TOKEN_JWK" | grep -q "ES256"; then
  hydra create jwk hydra.jwt.access-token --alg ES256 --use sig --endpoint $HYDRA_ADMIN_SERVICE_PATH || exit 1
  echo "✅ New ES256 key for access token created."
elif echo "$ACCESS_TOKEN_JWK" | grep -q "ES256"; then
  echo "✅ ES256 key for access token already exists. Skipping creation."
else
  echo "❌ Unexpected response: $ACCESS_TOKEN_JWK"
  exit 1
fi

ID_TOKEN_JWK=$(hydra get jwk hydra.openid.id-token --endpoint $HYDRA_ADMIN_SERVICE_PATH 2>&1 || true)

echo "🔑 Creating new ES256 ID token key (hydra.openid.id-token)..."
if echo "$ID_TOKEN_JWK" | grep -q '"error": "Not Found"' || ! echo "$ID_TOKEN_JWK" | grep -q "ES256"; then
  hydra create jwk hydra.openid.id-token --alg ES256 --use sig --endpoint $HYDRA_ADMIN_SERVICE_PATH || exit 1
  echo "✅ New ES256 key for ID token created."
elif echo "$ID_TOKEN_JWK" | grep -q "ES256"; then
  echo "✅ ES256 key for ID token already exists. Skipping creation."
else
  echo "❌ Unexpected response: $ID_TOKEN_JWK"
  exit 1
fi

echo ""
echo "Fetching updated access token keys (hydra.jwt.access-token)..."
hydra get jwk hydra.jwt.access-token --endpoint $HYDRA_ADMIN_SERVICE_PATH || exit 1

echo ""
echo "Fetching updated ID token keys (hydra.openid.id-token)..."
hydra get jwk hydra.openid.id-token --endpoint $HYDRA_ADMIN_SERVICE_PATH || exit 1
