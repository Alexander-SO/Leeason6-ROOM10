#!/usr/bin/env bash
# ============================================================
# setup.sh — node-express-chatbox
# Script de bootstrap para onboarding en menos de 5 minutos
# Uso: bash setup.sh
# ============================================================

set -e  # Detener en cualquier error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

NODE_MIN_VERSION=18

echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Setup — node-express-chatbox       ${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# ── 1. Verificar que Node.js esté instalado ──────────────────
echo -e "${YELLOW}[1/4] Verificando Node.js...${NC}"

if ! command -v node &> /dev/null; then
  echo -e "${RED}ERROR: Node.js no está instalado.${NC}"
  echo "   Opciones para instalarlo:"
  echo "   → Descarga directa: https://nodejs.org"
  echo "   → Con nvm:  nvm install ${NODE_MIN_VERSION} && nvm use ${NODE_MIN_VERSION}"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)

if [ "$NODE_VERSION" -lt "$NODE_MIN_VERSION" ]; then
  echo -e "${RED}ERROR: Se requiere Node.js v${NODE_MIN_VERSION} o superior.${NC}"
  echo "   Versión actual: $(node -v)"
  echo "   Usa nvm: nvm install ${NODE_MIN_VERSION} && nvm use ${NODE_MIN_VERSION}"
  exit 1
fi

echo -e "${GREEN}Node.js $(node -v) detectado${NC}"

# ── 2. Verificar que npm esté disponible ─────────────────────
echo ""
echo -e "${YELLOW}[2/4] Verificando npm...${NC}"

if ! command -v npm &> /dev/null; then
  echo -e "${RED}ERROR: npm no está disponible.${NC}"
  exit 1
fi

echo -e "${GREEN}npm $(npm -v) detectado${NC}"

# ── 3. Instalar dependencias ──────────────────────────────────
echo ""
echo -e "${YELLOW}[3/4] Instalando dependencias...${NC}"
npm install
echo -e "${GREEN}Dependencias instaladas correctamente${NC}"

# ── 4. Preparar archivo de entorno ───────────────────────────
echo ""
echo -e "${YELLOW}[4/4] Configurando variables de entorno...${NC}"

if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${GREEN} Archivo .env creado desde .env.example${NC}"
else
  echo -e "${GREEN}El archivo .env ya existe, no se sobreescribió${NC}"
fi

# ── Resumen final ─────────────────────────────────────────────
PORT_VALUE=$(grep PORT .env | cut -d= -f2)

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}   ¡Setup completado con éxito!    ${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "  Para iniciar la aplicación:"
echo ""
echo -e "  ${BLUE}node server.js${NC}          → inicio simple"
echo -e "  ${BLUE}make start${NC}              → usando Makefile"
echo -e "  ${BLUE}docker compose up${NC}       → usando Docker"
echo ""
echo -e "  La app estará disponible en: ${BLUE}http://localhost:${PORT_VALUE}${NC}"
echo ""
