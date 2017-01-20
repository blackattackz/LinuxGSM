#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods along with mods_list.sh and mods_core.sh.

local commandname="MODS"
local commandaction="addons/mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_core.sh

fn_mods_install_init(){
	fn_print_header
	# Display installed mods
	fn_installed_mods_light_list
	echo ""
	echo "Available addons/mods"
	echo "================================="
	
	# Display available mods from mods_list.sh
	fn_mods_show_available
	echo ""
	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; do
			echo -en "Enter an ${cyan}addon/mod${default} to ${green}install${default} (or exit to abort): "
			read -r usermodselect
			# Exit if user says exit or abort
			if [ "${usermodselect}" == "exit" ]||[ "${usermodselect}" == "abort" ]; then
					core_exit.sh
			# Supplementary output upon invalid user input 
			elif [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; then
				fn_print_error2_nl "${usermodselect} is not a valid addon/mod."
			fi
	done
	# Gives a pretty name to the user and get all mod info
	currentmod="${usermodselect}"
	fn_mod_get_info_from_command
	fn_print_dots_nl "Installing ${modprettyname}"
	sleep 1
	fn_script_log "Installing ${modprettyname}."
}

# Run all required operation
fn_mod_installation(){
	# If a mod was selected
	if [ -n "${currentmod}" ]; then
		# Get mod info
		fn_mod_get_info_from_command
		# Check if mod is already installed
		fn_mod_already_installed
		# Check and create required files
		fn_mods_files
		# Clear lgsm/tmp/mods dir if exists then recreate it
		fn_clear_tmp_mods
		fn_mods_tmpdir
		# Download mod
		fn_mod_dl
		# Extract the mod
		fn_mod_extract
		# Convert to lowercase if needed
		fn_mod_lowercase
		# Build a file list
		fn_mod_fileslist
		# Copying to destination
		fn_mod_copy_destination
		# Ending with installation routines
		fn_mod_add_list
		# Post install fixes
		fn_postinstall_tasks
		# Cleaning
		fn_clear_tmp_mods
		fn_print_ok_nl "${modprettyname} installed"
		fn_script_log "${modprettyname} installed."
	else
		fn_print_fail "No addon/mod was selected"
		exitcode="1"
		core_exit.sh
	fi
}

fn_mods_install_init
fn_mod_installation
core_exit.sh
