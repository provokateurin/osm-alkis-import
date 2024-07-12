#!/bin/bash
set -euxo pipefail

ogr2ogr -overwrite -nlt MULTIPOLYGON "PG:host=localhost user=postgres" data/hu_shp.shp -spat 288031 5621613 303367 5638058 &
ogr2ogr -overwrite -nlt MULTIPOLYGON "PG:host=localhost user=postgres" data/gis_osm_buildings_a_free_1.shp -t_srs EPSG:25832 -spat 5.98921 50.71607 6.21110 50.85495 &

wait

psql -h localhost -U postgres < conflate.sql
