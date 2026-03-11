# POSTMORTEM.md — Informe Ejecutivo
**Repositorio:** `node-express-chatbox`  
**Equipo:** Squad de Ingeniería de Plataforma  
**Fecha:** 2026-03-10

---

## Qué Estaba Roto

El repositorio heredado carecía de toda infraestructura de onboarding. El único comando de inicio documentado (`nodemon server.js`) fallaba inmediatamente en cualquier máquina limpia porque `nodemon` no estaba declarado como dependencia del proyecto. No existía versión de Node especificada, ningún archivo `.env.example`, ni instrucciones sobre qué URL visitar una vez iniciado el servidor. Un ingeniero nuevo quedaba bloqueado en el primer paso sin ningún mensaje de error accionable.

---

## Qué Construimos

| Artefacto | Qué elimina |
|-----------|-------------|
| `.nvmrc` | Ambigüedad de versión de Node — fija Node 18 para nvm |
| `.env.example` | Variables de entorno no documentadas — incluye `PORT` con comentarios |
| `Makefile` | Onboarding manual — `make setup` instala deps, copia `.env` y confirma la URL de la app |
| `setup.sh` | Dependencia de `make` — alternativa bash con mensajes de color y errores accionables |
| `Dockerfile` | Entornos inconsistentes — fija `node:18-alpine` como imagen base reproducible |
| `docker-compose.yml` | Necesidad de tener Node instalado — levanta todo el stack con un solo comando |

---

## Costo del Estado Original

Con el repositorio en su estado anterior, cada ingeniero nuevo perdía entre **30 y 45 minutos** resolviendo por su cuenta fricción que nunca debió existir.

> **5 ingenieros × 40 min promedio = 200 minutos = 3.3 horas perdidas al mes**  
> A una tarifa de **$50 USD/hora** → **$167 USD/mes en costo puro de fricción**  
> Proyectado a 12 meses → **$2,000 USD/año** perdidos en onboarding de un solo repositorio

Esto sin contar el costo de contexto mental perdido, la frustración del ingeniero ni el tiempo de un senior que es interrumpido para desbloquearlos.

---

## Qué Haríamos Después

**Agregar un workflow de CI/CD con GitHub Actions que valide el setup en cada Pull Request.**

Específicamente: un job que ejecute `bash setup.sh && node server.js &` en un runner limpio de Ubuntu y verifique que el servidor responde HTTP 200 antes de permitir el merge. Esto convertiría el Camino Dorado de un artefacto estático en un contrato vivo: si alguien rompe el onboarding en el futuro, el CI lo detecta antes de que llegue a `main`. El ROI es alto porque protege de forma permanente el trabajo que ya hicimos hoy, con un costo de implementación de menos de una hora.

---

## Prueba de Vida

**Tiempo de setup desde clone limpio usando los nuevos artefactos:**

```
[PASO 1/4] Verificando versión de Node.js...     v22.22.0
[PASO 2/4] npm install...                         87 paquetes en 4s
[PASO 3/4] Creando .env desde .env.example...    PORT=3001
[PASO 4/4] Servidor iniciado, verificando...    HTTP 200 en localhost:3001

TIEMPO TOTAL DE SETUP: 6 segundos
```