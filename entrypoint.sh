#!/bin/sh
set -e

# Navigate to the working directory
echo "Navigating to ${INPUT_WORKINGDIR}"

cd "${INPUT_WORKINGDIR:-.}"

# Find the template file
echo "Find the template file (${INPUT_TEMPLATEFILE})"

if ( [ ! -f "${INPUT_TEMPLATEFILE}" ] &&  $INPUT_TEMPLATEFILE != *.pkr.hcl ] ]); then
    echo "${INPUT_TEMPLATEFILE} does not exit in the working directory (${INPUT_WORKINGDIR})"
    exit 1
fi

# Find the var file file and it should be a json file
echo "Find the var file"

if [[ ! -f "${INPUT_VARFILE}" ]] && [[ $INPUT_VARFILE != *.pkr.hcl ]]; then
    echo "$INPUT_VARFILE not found in the working directory (${INPUT_WORKINGDIR})"
    exit 1
fi

# #check if variable file is supply
variableCommand=""
if [ -f "$INPUT_VARFILE" ]; then
    variableCommand="-var-file=$INPUT_VARFILE"
fi

set +e
# Run Packer init
echo "Run Packer init"
PACKER_INIT_OUTPUT=$(sh -c "packer init ${variableCommand} ${INPUT_TEMPLATEFILE}" 2>&1)
echo "$PACKER_INIT_OUTPUT"
echo "Ending running packer init ..."
set -e

set +e
# Run Packer validate
echo "Run Packer validate
PACKER_VALIDATE_OUTPUT=$(sh -c "packer validate ${variableCommand} ${INPUT_TEMPLATEFILE}" 2>&1)
echo "$PACKER_VALIDATE_OUTPUT"
echo "Ending running packer validate ..."
set -e

set +e
# Run Packer build
echo "Beginning running packer build ..."
BUILD_OUTPUT=$(sh -c "packer build ${variableCommand} ${INPUT_TEMPLATEFILE}" 2>&1)
BUILD_SUCCESS=$?
echo "$BUILD_OUTPUT"
set -e

exit $BUILD_SUCCESS
