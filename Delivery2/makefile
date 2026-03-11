# ============================================================
# Makefile — node-express-chatbox
# Uso: make setup   → instala todo y prepara el entorno
#      make start   → inicia el servidor
#      make dev     → inicia con recarga automática (nodemon)
#      make clean   → elimina node_modules
# ============================================================

.PHONY: setup start dev clean check-node

# Versión mínima de Node requerida
NODE_MIN_VERSION := 18

setup: check-node
	@echo ""
	@echo "Instalando dependencias..."
	npm install
	@echo ""
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Archivo .env creado desde .env.example"; \
	else \
		echo " El archivo .env ya existe, no se sobreescribió"; \
	fi
	@echo ""
	@echo " ¡Setup completado!"
	@echo "Para iniciar la app ejecuta: make start"
	@echo "🌐 Luego abre tu navegador en: http://localhost:$$(grep PORT .env | cut -d= -f2)"
	@echo ""

start:
	@echo "Iniciando servidor..."
	node server.js

dev:
	@echo "Iniciando servidor con recarga automática..."
	npx nodemon server.js

clean:
	@echo "Eliminando node_modules..."
	rm -rf node_modules
	@echo "Limpieza completada"

check-node:
	@echo "🔍 Verificando versión de Node.js..."
	@NODE_VERSION=$$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1); \
	if [ -z "$$NODE_VERSION" ]; then \
		echo "ERROR: Node.js no está instalado."; \
		echo "   Instálalo desde https://nodejs.org o usa nvm:"; \
		echo "   nvm install $(NODE_MIN_VERSION) && nvm use $(NODE_MIN_VERSION)"; \
		exit 1; \
	elif [ "$$NODE_VERSION" -lt "$(NODE_MIN_VERSION)" ]; then \
		echo "ERROR: Se requiere Node.js v$(NODE_MIN_VERSION) o superior."; \
		echo "   Versión actual: v$$NODE_VERSION"; \
		echo "   Usa nvm: nvm install $(NODE_MIN_VERSION) && nvm use $(NODE_MIN_VERSION)"; \
		exit 1; \
	else \
		echo "Node.js v$$NODE_VERSION detectado (mínimo requerido: v$(NODE_MIN_VERSION))"; \
	fi