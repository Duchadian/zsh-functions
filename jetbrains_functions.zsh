change_pycharm_project() {
  base_url="$HOME/$CCP_BASE"
  project_to="$(/bin/ls $base_url | fzf --preview "ls -alh $base_url/{}")"

  if [[ "${project_to}" != "" ]]; then
    pycharm "${base_url}/${project_to}" >/dev/null 2>&1 &
  fi
}


alias pcp='change_pycharm_project'
