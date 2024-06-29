# OSM ALKIS import

## Downloading the datasets

```sh
./download.sh
```

## Setting up the database

```sh
./db.sh &
```

## Running the conflation

```sh
./conflate.sh
```

## Viewing the results

I'm using QGIS with the following layers loaded (connect to the local Postgres instance first):

1. NRW DOP Farbe
2. `gis_osm_buildings_a_free_1` (Simple Fill; Color pink)
3. `hu_shp` (Outline: Simple Line; Color Yellow; Stroke width 0.35)
4. `matches.alkis_geom` (Outline: Simple Line; Color Green; Stroke width 0.5)
5. `matches.osm_geom` (Outline: Simple Line; Color Red; Stroke width 0.5)

## Problems found in the datasets and possible solutions

In the remaining unmatched buildings some patterns emerged which make them unmatchable at the moment:

- One dataset contains a building that is made up from multiple buildings in the other dataset and vice versa. Combining adjacent buildings and matching them together against the other building can fix this.
- Buildings built in a row are all offset by and amount that makes it ambiguous what the correct match is. Offsetting adjacent buildings can fix this.
- Matching accuracy and performance could be improved by not only matching geometries but also attributes.
