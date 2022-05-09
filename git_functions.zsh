clone_azdo_repo() {
  REPOS=$(az repos list --organization "$AZDO_ORG" --project "$AZDO_PROJECT")
  SEL=$(jq '.[].name' <<< $REPOS | fzf)
  SEL_JSON=$(jq ".[] | select(.name == ${SEL})" <<< $REPOS )
  cd "$HOME/$CCP_BASE"
  git clone "$(jq '.remoteUrl' -r <<< $SEL_JSON )"

}

clone_gitlab_repo() {
  if [ -z "$1" ]; then prefix=""; else prefix="${1}."; fi
  REPOS=$(glab api --paginate "/projects?simple=true&owned=true&order_by=updated_at" | jq 'del(.[].description)' -cM)
  SEL=$(jq '.[].path' <<< $REPOS  | fzf)

  if [[ "$SEL" != "" ]]; then
    SEL_JSON=$(jq ".[] | select(.path == ${SEL})" <<< $REPOS)
    cd "$HOME/$CCP_BASE"
    git clone "$( jq '.ssh_url_to_repo' -r <<< $SEL_JSON)" "${prefix}$(jq -r '.path' <<< $SEL_JSON)"
  else
    echo "No repo selected, exiting"
  fi
}

checkout_git_branch() {
  result=$(git branch -a | fzf | tr -d "[:space:]")
  if [[ $result != "" ]]; then
    result=$(echo $result | sed "s:remotes/origin/::g")
    git checkout "$result"
  else
    echo "No branch selected, exiting"
  fi
}

checkout_git_tag() {
  result=$(git tag | fzf | tr -d "[:space:]")
  if [[ $result != "" ]]; then
    git checkout "$result"
  else
    echo "No tag selected, exiting"
  fi
}

alias cazp='clone_azdo_repo'
alias cglp='clone_gitlab_repo'
alias gco='checkout_git_branch'
alias gcot='checkout_git_tag'
