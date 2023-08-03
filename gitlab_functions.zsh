switch_terraform_state() {
  currentRepo=$(git remote get-url origin | cut -d ':' -f 2 | cut -d '.' -f 1)
  echo "looking for terraform states in ${currentRepo}"
  repo=$(glab api graphql --paginate -f query="
    query {
      project(fullPath: \"${currentRepo}\") {
        id
        terraformStates {
          count
          nodes {
            name
          }
        }
      }
    }")
  states=$(jq -r '.data.project.terraformStates' <<< "${repo}")
  projectId=$(jq -r '.data.project.id' <<< "${repo}" | awk -F/ '{print $NF}')
  nStates=$(jq '.count' <<< "${states}")

  if [[ ${nStates} -gt 0 ]]; then
    echo "This repo has ${nStates} states, choose one"
    select ITEM in $(jq -r '.nodes[].name' <<< "${states}"); do
      host=$(glab config get host)
      TF_STATE_ADDRESS="https://${host}/api/v4/projects/${projectId}/terraform/state/${ITEM}"
      echo terraform init \
          -backend-config="address=${TF_STATE_ADDRESS}" \
          -backend-config="lock_address=${TF_STATE_ADDRESS}/lock" \
          -backend-config="unlock_address=${TF_STATE_ADDRESS}/lock" \
          -backend-config="username=${GITLAB_USER}" \
          -backend-config="password=${GITLAB_ACCESS_TOKEN}" \
          -backend-config="lock_method=POST" \
          -backend-config="unlock_method=DELETE" \
          -backend-config="retry_wait_min=5"
      break
    done
  else
    echo 'This repo has no states, create one'
  fi
}


alias sts='switch_terraform_state'