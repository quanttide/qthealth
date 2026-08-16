// 量潮健康 provider——HTTP 服务入口。
//
// 参考 qtcloud-secret / qtcloud-devops provider 模式：
// cmd/server（入口）+ internal/{model,handler}（分层）。
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

// healthHandler 健康检查端点。
func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": "qthealth-provider"})
}

// statusHandler 健康状态占位端点。
func statusHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{
		"service": "qthealth-provider",
		"status":  "占位（骨架初始化）",
	})
}

func main() {
	addr := os.Getenv("QTHEALTH_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", healthHandler)
	mux.HandleFunc("GET /api/status", statusHandler)
	log.Printf("qthealth-provider 监听 %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
