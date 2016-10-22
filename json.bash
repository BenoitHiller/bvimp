set -f

declare -r JSON_STRING='"(([^"\]|\\["\/bfnrt]|\\u[[:xdigit:]]{4})*)"'
declare -r JSON_NUMBER='(-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][+-]?[0-9]+)?)'
declare -r JSON_LITERAL='(true|false|null)'

json_readObject() {
  while read -r token; do
    if [[ "$token" == "}" ]]; then
      return 0
    elif [[ "$token" == "," ]]; then
      continue
    fi
    token="${token:1:${#token}-2}"
    read -r separator
    json_readValue "$1/$token"
  done
  return 1
}

json_readArray() {
  local -i index=0
  while true; do
    json_readValue "$1/$((index++))"
    read -r token
    if [[ "$token" == "]" ]]; then
      return 0
    elif [[ "$token" != "," ]]; then
      return 1
    fi
  done

}

json_parseTerminal() {
  if [[ "$2" =~ $JSON_STRING ]]; then
    _output["$1"]=${BASH_REMATCH[1]}
  else
    _output["$1"]=$2
  fi
}

json_readValue() {
  read -r token
  case "$token" in
    '{')
      json_readObject "$1"
      ;;
    '[')
      json_readArray "$1"
      ;;
    *)
      json_parseTerminal "$1" "$token"
      ;;
  esac
  return "$?"
}

json_split() {
  grep -Eo "$JSON_STRING|$JSON_NUMBER|$JSON_LITERAL|[[:space:]]+|." | grep -Ev '^[[:space:]]*$'
}

# parse json into an associative array
#
# The specified array is populated by generating a key from the parent field
# names and indices, joined with a "/". The top level is denoted with a ".".
#
# e.g.
#   [ { "a": true } ]
# places a single value in the array:
#   array["./0/a"]=true
#
# Note:
#   * If the json is invalid the result of parsing is undefined
#   * Strings are not decoded
#   * The parser may return 1 in cases where it did not parse successfully
# 1._output a reference to the target array
# &0. the input json is read on stdin
parseJson() {
  local -n _output="$1"
  json_readValue "." < <(json_split)
  return "$?"
}
