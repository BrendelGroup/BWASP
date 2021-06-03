#!/bin/bash

# bwasp_env.sh - a helper script to set variables identifying the BWASP root
#   and datadirectories as well as the prefix for running commands within the
#   downloaded bwasp.sif singularity container

echo ""
echo "NOTE. This simple script only works as described in the BWASP INSTALL"
echo "document under the following assumptions:"
echo ""
echo "  - bwasp_env.sh resides in the BWASP/bin directory, and the BWASP directory"
echo "    structure was not changed after cloning the respository."
echo "  - The bwasp.sif singularity container was put into the BWASP directory."
echo ""
echo "The INSTALL instructions"
echo ""
echo "    git clone https://github.com/brendelgroup/BWASP.git"
echo "    cd BWASP"
echo "    singularity pull http://BrendelGroup.org/SingularityHub/bwasp.sif"
echo "    source bin/bwasp_env.sh"
echo ""
echo "are consistent. If you know basic 'bash' and 'singularity' commands,"
echo "you can easily adjust this script to your needs and preferences."
echo ""

# 1. BWASP_ROOT and BWASP_DATA are set based on where the bwasp_env.sh script
#   is located:

BWASP_ROOT=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)")
BWASP_DATA=${BWASP_ROOT}/data
CONTAINER=${BWASP_ROOT}/bwasp.sif

if [ ! -f ${CONTAINER} ]; then
  echo "${CONTAINER} not found. Please get the container as described."
  exit
fi

# 2. Creating a prefix for singularity use:
#
BWASP_EXEC="singularity exec -e -B ${BWASP_DATA} $CONTAINER"
#
# -e is --cleanenv
# -B is --bind

# 3. Finishing up:
#
export BWASP_ROOT
export BWASP_DATA
export BWASP_EXEC

echo "ALL DONE. In this (and only this) shell, you can now use the variables"
echo ""
echo '  $BWASP_ROOT'" (set to:	$BWASP_ROOT	)"
echo '  $BWASP_DATA'" (set to:	$BWASP_DATA	)"
echo '  $BWASP_EXEC'" (set to:	$BWASP_EXEC	)"
echo ""
echo "For example:"
echo ""
echo '  $BWASP_EXEC which filterMsam.pl'
echo '  $BWASP_EXEC filterMsam.pl'
echo ""
echo "will show (container) location and usage for the BWASP script filterMsam.pl."
echo ""
echo "FINAL NOTE. The -B option to singularity gives access to $BWASP_DATA. If you"
echo "want to analyze your own data in a different directory, set up as follows:"
echo ""
echo '  export BWASP_EXEC="singularity exec -e -B <datadir> <bwasp.sif full path>"'
echo ""
echo "where <datadir> points to the location of your data, and <bwasp.sif full path>"
echo "points to the location of the bwasp.sif singularity image file."
echo ""
echo "Do read up on and support SingularityCE (https://sylabs.io/docs/)."
