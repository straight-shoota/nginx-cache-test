BACKEND_PORT=8022
FRONTEND_PORT=8021

frontend="127.0.0.1:${FRONTEND_PORT}/"
backend="127.0.0.1:${BACKEND_PORT}/"

# clear cache
find cache -type f -delete 

# test backend

bg_counter=$(curl -vs "$backend")

fg_counter=$(curl -vs "$frontend")

if [[ "1" -ne "$(expr $fg_counter - $bg_counter)" ]]; then
  echo "FAILED: backend counter was $bg_counter, frontend counter $fg_counter"
  exit 1
fi

cached_counter=$(curl -vs "$frontend")

if [[ "0" -ne "$(expr $fg_counter - $cached_counter)" ]]; then
  echo "FAILED: frontend counter $fg_counter was not cached (got $cached_counter)"
  exit 2
else
  echo "=== Counter was successfully retrieved from cache ($cached_counter)"
fi

bypassed_counter=$(curl -vs "$frontend" -H "cachepurge: true")

if [[ "1" -ne "$(expr $bypassed_counter - $fg_counter)" ]]; then
  echo "FAILED: could not bypass counter (retrieved $bypassed_counter)"
  exit 3
else
  echo "=== Bypass works correctly ($bypassed_counter)"
fi

new_cached_counter=$(curl -vs "$frontend")

if [[ "0" -ne "$(expr $bypassed_counter - $new_cached_counter)" ]]; then
  echo "FAILED: retrieved a different value on subsequental run: $new_cached_counter"
  exit 4
fi

echo "bg_counter: ${bg_counter}"
echo "fg_counter: ${fg_counter}"
echo "cached_counter: ${cached_counter}"
echo "bypassed_counter: ${bypassed_counter}"
echo "new_bypassed_counter: ${new_cached_counter}"
