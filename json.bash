#!/bin/bash

set -f

declare -r STRING='"(([^"\]|\\["\/bfnrt]|\\u[[:xdigit:]]{4})*)"'
declare -r NUMBER='(-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][+-]?[0-9]+)?)'
declare -r LITERAL='(true|false|null)'

readObject() {
  while read -r token; do
    if [[ "$token" == "}" ]]; then
      return 0
    elif [[ "$token" == "," ]]; then
      continue
    fi
    token="${token:1:${#token}-2}"
    read -r separator
    readValue "$1/$token"
  done
  return 1
}

readArray() {
  local -i index=0
  while true; do
    readValue "$1/$((index++))"
    read -r token
    if [[ "$token" == "]" ]]; then
      return 0
    elif [[ "$token" != "," ]]; then
      return 1
    fi
  done

}

parseTerminal() {
  if [[ "$2" =~ $STRING ]]; then
    _output["$1"]=${BASH_REMATCH[1]}
  else
    _output["$1"]=$2
  fi
}

readValue() {
  read -r token
  case "$token" in
    '{')
      readObject "$1"
      ;;
    '[')
      readArray "$1"
      ;;
    *)
      parseTerminal "$1" "$token"
      ;;
  esac
  return "$?"
}

splitJson() {
  grep -Eo "$STRING|$NUMBER|$LITERAL|[[:space:]]+|." | grep -Ev '^[[:space:]]*$'
}

parseJson() {
  local -n _output="$1"
  readValue "." < <(splitJson)
  return "$?"
}

declare -A output=()
parseJson output <test1.json

for key in "${!output[@]}"; do
  printf "%s: %s\n" "$key" "${output[$key]}"
done
