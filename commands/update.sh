#!/usr/bin/env bash
# Author: cbweaver (https://github.com/cbweaver)
# Description: Apply all pending updates

# Purpose: Update a given webite
# Arguments:
#   None
function update {
  # 1. Collect and test arguments
  # 2. Update

  #=============================================================================
  #===  1. Collect and test arguments
  #=============================================================================

  local options=":w:"

  local website_path=""
  while getopts "$options" o; do
    case "${o}" in
      w)
        website_path="${OPTARG}"
        ;;
      *)
        echo "${o}"
        usage update
        exit "${error[bad_arg]}"
        ;;
    esac
  done
  shift $((OPTIND-1))

  # Evaluate arguments
  #   1. website_path must be set
  #   2. website_path must be:
  #     2a. a directory
  #     2b. a valid CMS root

  # 1. website_path must be set
  if [[ -z "$website_path" ]]; then
    msg "ERROR" "Missing path to website"
    usage backup
    exit "${error[missing_required_args]}"
  fi

  # 2a. website_path must be a directory
  if [[ ! -d "$website_path" ]]; then
    msg "ERROR" "Website path ($website_path) is not a directory"
    exit "${error[bad_arg]}"
  fi

  # 2b. website_path must be a valid CMS root
  local website_type=""
  get_website_type "$website_path" website_type
  # Errors are handled within get_website_type.

  #=============================================================================
  #===  2. Update
  #=============================================================================

  msg "COMMENT" "$website_type website detected. Updating..."
  case "$website_type" in
    Drupal)
      _update_drupal "$website_path"
      ;;
    WordPress)
      _update_wordpress "$website_path"
      ;;
  esac
}


# Purpose: Update a Drupal website to latest core and module releases
# Arguments:
#   1. website_path
function _update_drupal {
  if [[ $# -ne 1  ]]; then
    msg "ERROR" "_update_drupal takes one argument:"
    msg "ERROR" "  website_path: The full path to the Drupal website to be updated"
    exit "${error[wrong_number_of_args]}"
  fi

  local website_path="$1"
  cd "$website_path"

  drush up --no-backup -y
}

# Purpose: Update a WordPress website to latest core and plugin releases
# Arguments:
#   1. website_path
function _update_wordpress {
  if [[ $# -ne 1  ]]; then
    msg "ERROR" "_update_wordpress takes one argument:"
    msg "ERROR" "  website_path: The full path to the WordPress website to be updated"
    exit "${error[wrong_number_of_args]}"
  fi

  local website_path="$1"
  cd "$website_path"

  wp core update && wp core update-db
}
