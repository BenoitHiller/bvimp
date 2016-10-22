#!/bin/bash

set -f

declare -r STRING_REGEX='^[[:space:]]*"(([^"\]|\\["\/bfnrt]|\\u[[:xdigit:]]{4})*)"(.*)'
declare -r NUMBER_REGEX='^[[:space:]]*(-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][+-]?[0-9]+)?)(.*)'
declare -r LITERAL_REGEX='^[[:space:]]*(true|false|null)(.*)'

declare -r OBJECT_OPEN='^[[:space:]]*\{(.*)'
declare -r OBJECT_INNER='^[[:space:]]*:(.*)'
declare -r OBJECT_CLOSE='^[[:space:]]*\}(.*)'

declare -r ARRAY_OPEN='^[[:space:]]*\[(.*)'
declare -r ARRAY_CLOSE='^[[:space:]]*\](.*)'

declare -r SEPARATOR='^[[:space:]]*,(.*)'

popEntry() {
  local key
  if [[ "$input" =~ $STRING_REGEX ]]; then
    key=${BASH_REMATCH[1]}
    input=${BASH_REMATCH[3]}
    if [[ "$input" =~ $OBJECT_INNER ]]; then
      input=${BASH_REMATCH[1]}
      popValue "$1/$key"
      return "$?"
    else
      return 1
    fi
  else
    return 1
  fi
}

popObject() {
  if [[ "$input" =~ $OBJECT_OPEN ]]; then
    input=${BASH_REMATCH[1]}
    popEntry "$1"
    while [[ "$input" =~ $SEPARATOR ]]; do
      input=${BASH_REMATCH[1]}
      popEntry "$1" || return 1
    done
    if [[ "$input" =~ $OBJECT_CLOSE ]]; then
      input=${BASH_REMATCH[1]}
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

popArray() {
  local -i index=0
  if [[ "$input" =~ $ARRAY_OPEN ]]; then
    input=${BASH_REMATCH[1]}
    popValue "$1/$((index++))"
    while [[ "$input" =~ $SEPARATOR ]]; do
      input=${BASH_REMATCH[1]}
      popValue "$1/$((index++))" || return 1
    done
    if [[ "$input" =~ $ARRAY_CLOSE ]]; then
      input=${BASH_REMATCH[1]}
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

popValue() {
  popObject "$1" || popArray "$1" || popTerminal "$1"
  return "$?"
}

popTerminal() {
  if [[ "$input" =~ $STRING_REGEX ]]; then
    _output[$1]=${BASH_REMATCH[1]}
    input=${BASH_REMATCH[3]}
  elif [[ "$input" =~ $NUMBER_REGEX ]]; then
    _output[$1]=${BASH_REMATCH[1]}
    input=${BASH_REMATCH[6]}
  elif [[ "$input" =~ $LITERAL_REGEX ]]; then
    _output[$1]=${BASH_REMATCH[1]}
    input=${BASH_REMATCH[2]}
  else
    return 1
  fi
  return 0
}

parseJson() {
  local -n _output="$1"
  local input="$(cat)"
  popValue ""
  return "$?"
}

declare -A output=()
parseJson output <test2.json

for key in "${!output[@]}"; do
  printf "%s: %s\n" "$key" "${output[$key]}"
done
