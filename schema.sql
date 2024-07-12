CREATE TABLE combinations
(
    osm_id             TEXT                          NOT NULL,
    alkis_oi           TEXT                          NOT NULL,
    osm_geom           GEOMETRY(MULTIPOLYGON, 25832) NOT NULL,
    alkis_geom         GEOMETRY(MULTIPOLYGON, 25832) NOT NULL,
    alkis_geom_aligned GEOMETRY(MULTIPOLYGON, 25832) NOT NULL,
    status             INTEGER                       NOT NULL,
    last_updated       timestamptz                   NOT NULL,
    PRIMARY KEY (osm_id, alkis_oi)
);

CREATE FUNCTION tr_combinations_update_last_updated()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    NEW.last_updated := now();

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_combinations_update_last_updated
    BEFORE UPDATE
    ON combinations
    FOR EACH ROW
EXECUTE PROCEDURE tr_combinations_update_last_updated();
