#!/bin/bash
set -euxo pipefail

ogr2ogr -overwrite -nlt MULTIPOLYGON "PG:host=localhost user=postgres" data/hu_shp.shp &
ogr2ogr -overwrite -nlt MULTIPOLYGON "PG:host=localhost user=postgres" data/gis_osm_buildings_a_free_1.shp -t_srs EPSG:25832 &

wait

psql -h localhost -U postgres < conflate.sql
