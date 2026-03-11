# GOLDEN_PATH.md — El Camino Dorado
**Repositorio:** `https://github.com/danielc92/node-express-chatbox`  
**Equipo:** Squad de Ingeniería de Plataforma  
**Fecha:** 2026-03-10

---

## Qué es el Camino Dorado

El Camino Dorado es el conjunto de artefactos que eliminan cada punto de fricción identificado en el `PAIN_LOG.md`. El objetivo: cualquier ingeniero del equipo puede clonar el repositorio y tener la aplicación corriendo en menos de 5 minutos, sin conocimiento previo del proyecto.

---

## Cómo se usó IA

El `PAIN_LOG.md` completo fue pegado como contexto en Claude (claude.ai). Se usaron los siguientes prompts para generar los primeros borradores:

**Prompt 1 — Makefile:**
> "Dado este PAIN_LOG.md de un proyecto Node.js/Express/socket.io, genera un Makefile con un target `make setup` que: verifique la versión de Node, instale dependencias con npm install, copie .env.example a .env si no existe, y muestre la URL donde corre la app al finalizar. Debe tener mensajes de error claros en caso de fallar."

**Prompt 2 — setup.sh:**
> "Genera un script bash `setup.sh` para el mismo proyecto que haga las mismas verificaciones del Makefile pero con colores en terminal, mensajes de error accionables y compatibilidad con sistemas sin make instalado."

**Prompt 3 — docker-compose.yml + Dockerfile:**
> "Genera un docker-compose.yml y un Dockerfile para este proyecto Node.js que fijen Node 18, expongan el puerto desde variable de entorno PORT con fallback a 3001, y permitan levantar todo con `docker compose up`."

**Prompt 4 — .env.example y .nvmrc:**
> "Genera un .env.example con comentarios explicativos para todas las variables de entorno del proyecto, y un .nvmrc que fije Node 18."

---

## Artefactos Creados

| Archivo | Qué hace |
|---------|----------|
| `.nvmrc` | Fija la versión de Node en 18 para nvm |
| `.env.example` | Documenta todas las variables de entorno requeridas con comentarios |
| `Makefile` | Automatiza setup completo con `make setup`, incluye verificación de versión de Node |
| `setup.sh` | Alternativa al Makefile con colores y mensajes de error amigables |
| `docker-compose.yml` | Levanta el stack completo con `docker compose up` |
| `Dockerfile` | Fija Node 18-alpine, construye la imagen de forma reproducible |

---

## Tabla de Corrección: Puntos de Fricción → Artefactos

| # Pain Point | Descripción | Artefacto que lo Corrige | Estado |
|:---:|---|---|:---:|
| 1 | Sin versión de Node especificada | `.nvmrc` + `Makefile` (check-node) + `Dockerfile` (FROM node:18) | Corregido |
| 2 | `nodemon` no en devDependencies | `Makefile` usa `npx nodemon`; `make start` usa `node server.js` directamente | orregido |
| 3 | Sin script `npm start` | `Makefile` agrega `make start` como equivalente documentado | Corregido |
| 4 | Sin comando alternativo sin nodemon | `make start` → `node server.js`; `setup.sh` lo documenta explícitamente |Corregido |
| 5 | nodemon global rompe CI/CD | `make dev` usa `npx nodemon` (sin instalación global) | Corregido |
| 6 | Puerto hardcodeado sin documentar | `.env.example` documenta `PORT=3001`; `docker-compose.yml` lo hace configurable | Corregido |
| 7 | Sin `.env.example` aunque `.env` en .gitignore | `.env.example` creado con variables y comentarios |Corregido |
| 8 | Sin salida esperada ni URL documentada | `setup.sh` y `Makefile` imprimen la URL al finalizar el setup | Corregido |
| 9 | `package-lock.json` antiguo genera warnings | Fuera de alcance — requiere regenerar el lockfile commiteando el cambio | Parcial |
| 10 | URL de la app nunca mencionada | `make setup` y `setup.sh` muestran `http://localhost:PORT` al finalizar | Corregido |
| 11 | `res.sendfile()` deprecado | Fuera de alcance del equipo de plataforma — requiere cambio en el código fuente del app | Fuera de Alcance |
| 12 | Sin explicación de node_modules para junior | `setup.sh` incluye mensajes explicativos en cada paso | Corregido |

**Resumen:** 10 corregidos | 1 parcial | 1 fuera de alcance

---

## Instrucciones del Camino Dorado

Un ingeniero nuevo solo necesita ejecutar esto desde un clone limpio:

### Opción A — Con Make (recomendado)
```bash
git clone https://github.com/danielc92/node-express-chatbox.git
cd node-express-chatbox
make setup
make start
# Abre http://localhost:3001
```

### Opción B — Con script bash (sin make)
```bash
git clone https://github.com/danielc92/node-express-chatbox.git
cd node-express-chatbox
bash setup.sh
node server.js
# Abre http://localhost:3001
```

### Opción C — Con Docker (sin Node instalado localmente)
```bash
git clone https://github.com/danielc92/node-express-chatbox.git
cd node-express-chatbox
cp .env.example .env
docker compose up
# Abre http://localhost:3001
```

---

## Lo Que la IA Se Equivocó

### Error 1 — El Makefile usaba `$(shell node -v)` de forma incorrecta en la comparación
La IA generó la verificación de versión de Node usando expansión de shell de Make (`$(shell ...)`), pero la comparación numérica fallaba porque el resultado incluía la `v` del prefijo (`v22`) y Make no hace aritmética de strings nativamente. Fue necesario reescribir la verificación usando un bloque bash dentro del target con `sed` y comparación entera en bash puro.

**Lo que generó la IA:**
```makefile
NODE_VERSION := $(shell node -v | sed 's/v//')
check-node:
    @if [ $(NODE_VERSION) -lt 18 ]; then ...
```
**El problema:** `$(shell ...)` en Make se expande en tiempo de parseo y la comparación `-lt` no funciona con versiones semánticas (`18.20.0` falla). Se corrigió moviendo toda la lógica a un bloque `bash` dentro del target.

---

### Error 2 — El docker-compose.yml generado usaba `build: context: .` con sintaxis incorrecta
La IA generó el servicio con esta sintaxis:
```yaml
services:
  chatbox:
    build:
      context: .
      dockerfile: Dockerfile
```
Esto es válido en Docker Compose v3, pero el Dockerfile generado por la IA en el mismo prompt usaba `ARG PORT` sin declararlo correctamente antes del `EXPOSE`, haciendo que el build fallara con `invalid reference format`. Se corrigió simplificando el Dockerfile para usar solo `ENV PORT=3001` con valor por defecto y eliminando el ARG innecesario.

---

### Error 3 — La IA omitió el volumen de `node_modules` en docker-compose
El primer borrador del `docker-compose.yml` no incluía el volumen anónimo para `node_modules`:
```yaml
volumes:
  - .:/app
```
Esto causaba que el bind mount sobreescribiera el `node_modules` instalado dentro del contenedor con el (inexistente) `node_modules` del host. Se agregó manualmente:
```yaml
volumes:
  - .:/app
  - /app/node_modules
```
Este es un patrón conocido en Docker + Node pero la IA lo olvidó en el primer borrador.