#!/bin/bash
set -euxo pipefail

mkdir -p data

wget -nc -P data https://www.opengeodata.nrw.de/produkte/geobasis/lk/akt/hu_shp/hu_EPSG25832_Shape.zip
unzip -n -d data data/hu_EPSG25832_Shape.zip

wget -nc -P data https://download.geofabrik.de/europe/germany/nordrhein-westfalen/koeln-regbez-latest-free.shp.zip
unzip -n -d data data/koeln-regbez-latest-free.shp.zip
