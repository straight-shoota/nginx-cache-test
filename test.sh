BACKEND_PORT=8022
FRONTEND_PORT=8021

frontend="127.0.0.1:${FRONTEND_PORT}"
frontend_preview_token="${frontend}?preview_token=123456"
backend="127.0.0.1:${BACKEND_PORT}/"

function final_stats {
  echo "bg_counter: ${bg_counter}"
  echo "fg_counter: ${fg_counter}"
  echo "cached_counter: ${cached_counter}"
  echo "bypassed_counter: ${bypassed_counter}"
  echo "new_bypassed_counter: ${new_cached_counter}"
  echo "preview_token_counter: ${preview_token_counter}"
  echo "second_preview_token_counter: ${second_preview_token_counter}"
}

function fail {
  echo " ======== FAILED ========"
  echo "$1"
  final_stats
  exit 1
}

# clear cache
find cache -type f -delete 

# test backend

bg_counter=$(curl -vs "$backend")

fg_counter=$(curl -vs "$frontend")

if [[ "1" -ne "$(expr $fg_counter - $bg_counter)" ]]; then
  fail "backend counter was $bg_counter, frontend counter $fg_counter"
fi

cached_counter=$(curl -vs "$frontend")

if [[ "0" -ne "$(expr $fg_counter - $cached_counter)" ]]; then
  fail "frontend counter $fg_counter was not cached (got $cached_counter)"
else
  echo "=== Counter was successfully retrieved from cache ($cached_counter)"
fi

bypassed_counter=$(curl -vs "$frontend" -H "cachepurge: true")

if [[ "1" -ne "$(expr $bypassed_counter - $fg_counter)" ]]; then
  fail "could not bypass counter (retrieved $bypassed_counter)"
else
  echo "=== Bypass works correctly ($bypassed_counter)"
fi

new_cached_counter=$(curl -vs "$frontend")

if [[ "0" -ne "$(expr $bypassed_counter - $new_cached_counter)" ]]; then
  fail "retrieved a different value on subsequental run: $new_cached_counter"
fi

preview_token_counter=$(curl -vs "$frontend_preview_token")

if [[ "1" -ne "$(expr $preview_token_counter - $new_cached_counter)" ]]; then
  fail "preview_token counter was cached ($preview_token_counter)"
fi

second_preview_token_counter=$(curl -vs "$frontend_preview_token")

if [[ "1" -ne "$(expr $second_preview_token_counter - $preview_token_counter)" ]]; then
  fail "second_preview_token counter was cached ($second_preview_token_counter)"
fi

echo ""
echo "=== All tests succeeded ==="
echo ""

final_stats
