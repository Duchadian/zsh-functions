bw_get_item() {
  SEARCH_TERM=${1:?"A search term must be specified"}
  RESULT=$(bw list items --search $SEARCH_TERM)
  SIZE=$(jq '. | length | tonumber' <<< $RESULT)
  if [[ $SIZE > 1 ]]; then
    SELECTION=$(jq '.[].name' <<< $RESULT | fzf)
  else
    SELECTION=$(jq '.[0].name' <<< $RESULT)
  fi

  jq ".[] | select(.name == "$SELECTION") | .login" <<< $RESULT

}

alias bwi=bw_get_item
