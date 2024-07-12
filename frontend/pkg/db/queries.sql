-- name: GetNextTask :one
SELECT osm_id,
       alkis_oi,
       st_asgeojson(st_transform(st_forcepolygonccw(osm_geom), 'EPSG:3857'))::text   as osm_geom,
       st_asgeojson(st_transform(st_forcepolygonccw(alkis_geom), 'EPSG:3857'))::text as alkis_geom
FROM "public"."combinations"
WHERE "status" = 1
LIMIT 1;

-- name: SetTaskStatus :exec
UPDATE "public"."combinations"
SET "status" = $3
WHERE "osm_id" = $1
  AND "alkis_oi" = $2;
