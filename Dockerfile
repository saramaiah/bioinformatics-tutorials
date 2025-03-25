# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
## Modified from Jupyter Development Team's docker stacks (r-notebook and scipy-notebook) by Sara Ramaiah (https://github.com/saramaiah)
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # scipy-notebook things \
    ## for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html \
    build-essential \
    ## for latex labels \
    cm-super \
    dvipng \
    ## for matplotlib anim \
    ffmpeg \
    # r-notebook things \
    fonts-dejavu \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install Python 3 packages
RUN mamba install --yes \
    # scipy-notebook packages \
    'altair' \
    'beautifulsoup4' \
    'bokeh' \
    'bottleneck' \
    'cloudpickle' \
    'conda-forge::blas=*=openblas' \
    'cython' \
    'dask' \
    'dill' \
    'h5py' \
    'ipympl' \
    'ipywidgets' \
    'jupyterlab-git' \
    'matplotlib-base' \
    'numba' \
    'numexpr' \
    'numpy' \
    'openpyxl' \
    'pandas' \
    'patsy' \
    'protobuf' \
    'pyarrow' \
    'pyjanitor' \
    'pytables' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' \
    'widgetsnbextension' \
    'xlrd' \
    # r-notebook packages (trimmed down) \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidymodels' \
    'r-tidyverse' \
    # my added packages for R tutorials \
    'r-seurat' \
    'r-dplyr' \
    'r-patchwork' \
    'r-rismed' \
    # added packages for Python tutorials \
    'pooch' \
    'skimpy' \
    'scikit-bio' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# From scipy-notebook:
## Install facets package which does not have a `pip` or `conda-forge` package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets && \
    jupyter nbclassic-extension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

## Import matplotlib the first time to build the font cache
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

WORKDIR "${HOME}"
