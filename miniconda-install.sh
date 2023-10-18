#!/bin/bash

CONDA_SHELL=Mambaforge-$(uname)-$(uname -m).sh
CONDA_DIR=/var/lib/mambaforge
source /etc/os-release
LOCUSER=${LOCUSER:-$ID}

# 191025: Add a time-out limit on miniconda installation
# 2023-07 Changement d'installateur pour Mambaforge
# https://mamba.readthedocs.io/en/latest/installation.html#fresh-install
# ubuntu-ifb#7 : Problème d'installation de `mamba`
curl -LJO --connect-timeout 10 "https://github.com/conda-forge/miniforge/releases/latest/download/$CONDA_SHELL"
if [ ! -e $CONDA_SHELL ]; then
   echo "Miniconda3 installation timed out"
   return 1
fi
timeout 1m bash $CONDA_SHELL -b -u -p $CONDA_DIR
if [ $? -ne 0 ]; then
   echo "Miniconda3 installation timed out"
   return 1
fi
rm $CONDA_SHELL

# Configure conda environment
for conda_profile in $( ls $CONDA_DIR/etc/profile.d/*.sh ); do
   cp -a $conda_profile /etc/profile.d/
   source $conda_profile
done

## Add conda channels
#conda config --add channels R --system
conda config --add channels bioconda --system
conda config --add channels conda-forge --system

chgrp -R $LOCUSER $CONDA_DIR
chmod -R g+w $CONDA_DIR
