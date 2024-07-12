TRUNCATE combinations;

INSERT INTO combinations
SELECT gis_osm_buildings_a_free_1.osm_id,
       hu_shp.oi                               AS alkis_oi,
       gis_osm_buildings_a_free_1.wkb_geometry AS osm_geom,
       hu_shp.wkb_geometry                     AS alkis_geom,
       -- The ALKIS geometry is aligned to the OSM geometry using their centroids to calculate proper intersections
       st_translate(hu_shp.wkb_geometry,
                    st_x(st_centroid(gis_osm_buildings_a_free_1.wkb_geometry)) -
                    st_x(st_centroid(hu_shp.wkb_geometry)),
                    st_y(st_centroid(gis_osm_buildings_a_free_1.wkb_geometry)) -
                    st_y(st_centroid(hu_shp.wkb_geometry))
       )                                       AS alkis_geom_aligned,
       0                                       AS status,
       now()                                   as last_updated
FROM gis_osm_buildings_a_free_1,
     hu_shp
-- Intersections are expensive, so the bounding boxes are matched first
WHERE gis_osm_buildings_a_free_1.wkb_geometry && hu_shp.wkb_geometry
  AND st_intersects(gis_osm_buildings_a_free_1.wkb_geometry, hu_shp.wkb_geometry);

-- Apply quality filters
UPDATE combinations
SET status = 1
WHERE
  -- Centroids must lie within each others geometries
    abs(st_distance(st_centroid(osm_geom), st_centroid(alkis_geom))) < sqrt(st_area(osm_geom)) / 2
  AND abs(st_distance(st_centroid(osm_geom), st_centroid(alkis_geom))) < sqrt(st_area(alkis_geom)) / 2
  AND
  -- Difference between areas must not be too big
    abs(st_area(osm_geom) - st_area(alkis_geom)) < st_area(osm_geom) / 4
  AND abs(st_area(osm_geom) - st_area(alkis_geom)) < st_area(alkis_geom) / 4
  AND
  -- Aligned intersections must cover enough area of the original geometries
    st_area(st_intersection(osm_geom, alkis_geom_aligned)) / st_area(osm_geom) > 0.5
  AND st_area(st_intersection(osm_geom, alkis_geom_aligned)) / st_area(alkis_geom) > 0.5;

-- Remove duplicate combinations
UPDATE combinations
SET status = 0
WHERE osm_id IN (SELECT osm_id
                 FROM combinations
                 WHERE status = 1
                 GROUP BY osm_id
                 HAVING count(*) > 1)
   OR alkis_oi IN (SELECT alkis_oi
                   FROM combinations
                   WHERE status = 1
                   GROUP BY alkis_oi
                   HAVING count(*) > 1);

-- Delete all matches from the source data
DELETE
FROM gis_osm_buildings_a_free_1
WHERE exists(SELECT
             FROM combinations
             WHERE status = 1
               AND gis_osm_buildings_a_free_1.osm_id = combinations.osm_id);
DELETE
FROM hu_shp
WHERE exists(SELECT
             FROM combinations
             WHERE status = 1
               AND hu_shp.oi = combinations.alkis_oi);
