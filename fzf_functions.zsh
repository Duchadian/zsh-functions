code_change_project() {
  base_url="$HOME/Development/projects"
  project_to="$(ls $base_url | fzf)"

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

  code -g "$file_name:$line_number"
}

alias ccp='code -r "$HOME/development/projects/`ls $HOME/development/projects | fzf`"'
alias cof='code_open_file'
alias coft='code_open_file_with_term'

