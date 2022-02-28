#!/usr/bin/env bash
# This is the main entry point for the build system.

set -e

source core.functions

build_toolchain()
{
	if check_stamp toolchain; then
		return 0
	fi

	msg "Preparing environment for build"
	
	make_environment

	msg "Building cross-toolchain for '${STRAPY_BARCH}' architecture"

	msg "Cleaning up"
	
	find "${tools}" -name "*.la" -print0 | xargs -0 rm -rf
	find "${tools}" -name "*.pod" -print0 | xargs -0 rm -rf
	find "${tools}" -name ".packlist" -print0 | xargs -0 rm -rf

	stamp toolchain

	msg "Toolchain has been built successfully."
}

build_system()
{
	if ! check_stamp toolchain; then
		die "Build toolchain first."
	fi

	msg "Building base system for '${STRAPY_BARCH}' architecture"
    
    msg "This needs to be implmented..."
    
    sleep 4

    exit 0

	stamp system

	msg "Base system has been built successfully."
}

main()
{
	local mode

	case "$1" in
		target) shift; mode="build_target" ;;
		*)	die "Specify command" ;;
	esac


	while getopts a:k:c opts; do
		case $opts in
			a) export STRAPY_BARCH="$OPTARG" ;;
			k) export STRAPY_KERNEL="$OPTARG" ;;
			c) export STRAPY_NOCCACHE="1" ;;
		esac
	done
	shift $((OPTIND -1))

	msg 'Invoking on '"${date}"''

	case "$mode" in
		build_target)

			if [ -z "$1" ]; then
				die "Target is not specified."
			fi

			check_for_arch "$STRAPY_BARCH"

			msg "Exporting variables"
			export_variables "$STRAPY_BARCH"

			case "$1" in
				toolchain) build_toolchain ;;
				system) build_toolchain; build_system ;;
				*) die "Unknown target specified: $STRAPY_BARCH" ;;
			esac			
			;;
	esac
}

main "$@"

exit 0