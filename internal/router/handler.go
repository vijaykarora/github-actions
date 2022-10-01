package router

import (
	"context"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/vijaykarora/github-actions/internal/api/monitor"
	"log"
	"net/http"
	"time"
)

type Handler struct {
	router *gin.Engine
	server *http.Server
}

func NewHandler() *Handler {
	router := gin.New()
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(cors.Default())

	return &Handler{
		router: router,
		server: &http.Server{
			Addr:         ":3000",
			Handler:      router,
			ReadTimeout:  10 * time.Second,
			WriteTimeout: 10 * time.Second,
		},
	}
}

func (h *Handler) Run() {
	otherGroup := h.router.Group(BaseGroupPath + OtherGroup)
	otherGroup.GET(HealthPath, monitor.Health)

	go func() {
		if err := h.server.ListenAndServe(); err != nil {
			log.Println(err.Error())
		}
	}()
}

func (h *Handler) Shutdown(ctx context.Context) error {
	return h.server.Shutdown(ctx)
}
