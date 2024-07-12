package main

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"

	"github.com/provokateurin/osm-alkis-import/pkg/db"
)

func main() {
	ctx := context.Background()

	conn, err := pgx.Connect(ctx, "host=localhost user=postgres dbname=postgres")
	if err != nil {
		panic(err)
	}
	defer conn.Close(ctx)

	queries := db.New(conn)

	r := gin.Default()
	r.Static("/frontend", "./static")
	r.GET("/task/next", func(c *gin.Context) {
		getNextTask(ctx, conn, queries, c)
	})

	err = r.Run()
	if err != nil {
		panic(err)
	}
}

func getNextTask(ctx context.Context, conn *pgx.Conn, queries *db.Queries, c *gin.Context) {
	tx, err := conn.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		panic(err)
	}

	txQueries := queries.WithTx(tx)

	row, err := txQueries.GetNextTask(ctx)
	if err != nil {
		panic(err)
	}

	println(row.OsmGeom)

	err = txQueries.SetTaskStatus(ctx, db.SetTaskStatusParams{
		OsmID:   row.OsmID,
		AlkisOi: row.AlkisOi,
		Status:  2,
	})
	if err != nil {
		panic(err)
	}

	err = tx.Commit(ctx)
	if err != nil {
		panic(err)
	}

	c.JSON(http.StatusOK, gin.H{
		"osm_id":     row.OsmID,
		"alkis_oi":   row.AlkisOi,
		"osm_geom":   row.OsmGeom,
		"alkis_geom": row.AlkisGeom,
	})
}
