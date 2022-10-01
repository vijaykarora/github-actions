package main

import (
	"context"
	"github.com/vijaykarora/github-actions/internal/router"
	"log"
	"os"
	"os/signal"
	"time"
)

func main() {
	server := router.NewHandler()
	server.Run()
	log.Println("server is listening on port: 3000")

	// Wait for interrupt signal to gracefully shut down
	// the server with a timeout of 5 seconds.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit

	log.Println("shutdown server ...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("server shutdown:", err)
	}
	log.Println("server gracefully shut down")
}
