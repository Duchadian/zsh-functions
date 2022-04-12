code_change_project() {
  base_url="$HOME/$CCP_BASE"
  project_to="$(/bin/ls $base_url | fzf --preview "ls -alh $base_url/{}")"

  if [[ "${project_to}" != "" ]]; then
    code -r "${base_url}/${project_to}"
  fi
}

code_open_file() {
  fzf_result="$(fd -t f | fzf -e --print-query --preview 'bat --style=numbers --color=always {}')"
  if [[ "${fzf_result}" == "" ]]; then
    echo "User exited, stopping script"
  else
    n_lines=$(echo $fzf_result | wc -l)
  
    # only the query exists if this is true
    if [[ ${n_lines} == 1 ]]; then
      echo "no file selected, operating on query"
      file_to_open="$(echo ${fzf_result} | head -n 1)"
    else
      file_to_open="$(echo ${fzf_result} | tail -n 1)"
    fi
  
    echo "Opening '$file_to_open'"
    # if the user does not exit
    code -a "$file_to_open"
  fi
}

code_open_file_with_term() {
  # taken from fzf examples
  INITIAL_QUERY=""
  RG_PREFIX="rg  --line-number --no-heading --color=always --smart-case "
  result=$(FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse
  )
  file_name="$(echo $result | awk -F ':' '{print $1}')"
  line_number="$(echo $result | awk -F ':' '{print $2}')"

  if [[ $result != "" ]]; then
    code -g "$file_name:$line_number"
  else
    echo "No file selected, exiting"
  fi
}

clone_azdo_repo() {
  REPOS=$(az repos list --organization "$AZDO_ORG" --project "$AZDO_PROJECT")
  SEL=$(jq '.[].name' <<< $REPOS | fzf)
  SEL_JSON=$(jq ".[] | select(.name == ${SEL})" <<< $REPOS )
  cd "$HOME/$CCP_BASE"
  git clone "$(jq '.remoteUrl' -r <<< $SEL_JSON )"

}

clone_gitlab_repo() {
  if [ -z "$1" ]; then prefix=""; else prefix="${1}."; fi
  REPOS=$(glab api "/projects?simple=true&owned=true&order_by=updated_at" | jq 'del(.[].description)' -cM)
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

run_glue_job() {
  JOB=$(aws glue list-jobs --tags Owner=mrm --max-results 50 | jq '.JobNames[]' -r | fzf)
  if [[ -z $JOB ]]; then
    aws glue start-job-run --name $JOB
  else
    echo "No job selected, exiting"
  fi
}

alias ccp='code_change_project'
alias cof='code_open_file'
alias coft='code_open_file_with_term'
alias cazp='clone_azdo_repo'
alias cglp='clone_gitlab_repo'
alias gco='checkout_git_branch'
alias gcot='checkout_git_tag'
alias op='cd $HOME/$CCP_BASE/`/bin/ls $HOME/$CCP_BASE | fzf`'
alias rgj='run_glue_job'
