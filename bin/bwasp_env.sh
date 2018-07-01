#!/bin/bash

# This is a helper script to set the BWASP root directory
# and build the appropriate Singularity commands

# Here we do a little bit of magic to infer the root directory where BWASP
# was cloned, based on the location of this script itself.

BWASP_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)")

echo "BWASP root directory appears to be $BWASP_ROOT"

BWASP_DATA=${BWASP_ROOT}/data

echo "We will be binding ${BWASP_DATA} into the container."

# Then we look for Singularity containers in the root
# If there are mutliple, we just use the first one (which is kind of naive)

CONTAINERS=( ${BWASP_ROOT}/*.simg )

if [ ${#CONTAINERS[@]} -gt 1 ]; then
  echo "More than 1 container found in BWASP root directory."
fi

CONTAINER=${CONTAINERS[0]}

echo "Using container ${CONTAINER}"

# -e is --cleanenv
# -B is --bind

BWASP_EXEC="singularity exec -e -B ${BWASP_DATA} $CONTAINER"

echo "Singularity command to use is: "
echo $BWASP_EXEC

export BWASP_ROOT
export BWASP_DATA
export BWASP_EXEC
