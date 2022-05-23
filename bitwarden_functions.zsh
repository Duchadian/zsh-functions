alias bw_auth='export BW_SESSION=$(bw unlock --passwordfile ~/.bw_auth --raw)'

bw_get_item() {
  if ! [ -n "${BW_SESSION}" ]; then
    bw_auth 
  fi

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

