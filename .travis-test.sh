#! /bin/sh
set -e
$HOME/SageMath/sage -sh
# $HOME/SageMath/sage -pip install --upgrade --no-index -v .
pip install --upgrade --no-index -v .
exit
$HOME/SageMath/sage setup.py test
(cd docs && $HOME/SageMath/sage -sh -c "make html")
$HOME/SageMath/sage -pip uninstall .
