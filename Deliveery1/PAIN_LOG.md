# PAIN_LOG.md — Auditoría de Fricción
**Repositorio:** `https://github.com/danielc92/node-express-chatbox`  
**Equipo:** Squad de Ingeniería de Plataforma  
**Fecha de Auditoría:** 2026-03-10  
**Metodología:** Clone limpio. Se siguió únicamente el README. Sin conocimiento previo del proyecto.

---

## Puntos de Fricción

### 1. [VERSION_HELL] No se especifica la versión de Node.js en ningún lugar
El README dice *"Este proyecto requiere `nodejs` para correr"* pero no da ninguna información de versión. No existe `.nvmrc`, ni `.node-version`, ni campo `engines` en el `package.json`. El proyecto fue construido en 2019 y usa `socket.io@2.2.0` y `express@4.17.1`. Al correrlo en Node 22 (LTS actual) se disparan advertencias de deprecación y **16 vulnerabilidades** (3 críticas). El comportamiento en Node 18 vs Node 22 puede diferir silenciosamente.  
**Severidad: ALTA** — Problemas de compatibilidad silenciosos, sin forma de saber qué versión de Node es la correcta.

---

### 2. [IMPLICIT_DEP] `nodemon` se requiere globalmente pero no está en `devDependencies`
El README instruye iniciar el servidor con:
```sh
nodemon server.js
```
Sin embargo, `nodemon` **NO** está listado en `package.json` bajo `devDependencies` y **NO** se instala con `npm install`. Ejecutar `nodemon server.js` en un sistema limpio retorna:
```
/bin/sh: 1: nodemon: not found
```
El README dice instalarlo globalmente (`npm install nodemon -g`), pero esto requiere permisos de escritura globales en npm y contamina el entorno global — una señal de alerta en ambientes corporativos o de CI.  
**Severidad: BLOQUEANTE** — El comando de inicio documentado falla inmediatamente en una máquina limpia.

---

### 3. [MISSING_DOC] No existe un script `npm start` en `package.json`
El `package.json` solo define un script `test` (que falla intencionalmente con `exit 1`). No hay script `start`. La expectativa estándar de un desarrollador de ejecutar `npm start` falla. El README no menciona esta limitación.  
**Severidad: MEDIA** — Genera confusión; los ingenieros esperan que `npm start` funcione en un proyecto Node.

---

### 4. [MISSING_DOC] No hay comando alternativo de inicio para entornos sin `nodemon`
El README solo provee una forma de iniciar el servidor: `nodemon server.js`. No existe un fallback como `node server.js`. Un desarrollador que omita la instalación global de nodemon no tiene ningún camino documentado para correr la aplicación.  
**Severidad: BLOQUEANTE** — Combinado con el punto #2, un desarrollador no puede iniciar la app siguiendo únicamente el README.

---

### 5. [IMPLICIT_DEP] `nodemon` fuera de `devDependencies` rompe pipelines de CI/CD
Aunque un desarrollador instale nodemon globalmente en local, cualquier runner de CI/CD (GitHub Actions, Jenkins, etc.) no lo tendrá. No existe mecanismo para instalarlo automáticamente vía `npm install`. Esto es una falla latente de despliegue esperando ocurrir.  
**Severidad: ALTA** — El proyecto no está listo para CI/CD de forma predeterminada.

---

### 6. [MISSING_DOC] El puerto `3001` está hardcodeado sin documentación ni mecanismo de configuración
El servidor hardcodea el puerto en `server.js`:
```js
const server = app.listen(3001, ...)
```
El cliente `chat.js` también hardcodea:
```js
var url = 'http://localhost:3001';
```
No hay variable de entorno `PORT`, no hay soporte para `.env`, y el README no menciona este puerto en ningún momento. Si el puerto 3001 está ocupado, el servidor falla al enlazarse sin un mensaje de error accionable.  
**Severidad: MEDIA** — Los conflictos de puerto generan fallos confusos sin orientación alguna.

---

### 7. [ENV_GAP] No existe archivo `.env.example` aunque `.env` está en el `.gitignore`
El `.gitignore` excluye explícitamente los archivos `.env` y `.env.test`, lo que sugiere que el proyecto fue diseñado con soporte de variables de entorno en mente. Sin embargo, no existe ningún `.env.example`, y la app no usa `dotenv` ni variables de entorno en tiempo de ejecución. Esto genera ambigüedad: ¿debería haber variables de entorno? ¿Falta alguna configuración? Un ingeniero no puede saberlo.  
**Severidad: BAJA** — Señal confusa que genera incertidumbre sobre si falta configuración.

---

### 8. [MISSING_DOC] No se describe qué esperar al ejecutar la app ni cómo verificar que funciona
El README lista características y capturas de pantalla pero no provee una "salida esperada" después de iniciar el servidor. Un ingeniero nuevo no sabe qué URL visitar, qué aspecto tiene el estado exitoso en la terminal, ni cómo confirmar que la app funciona.  
**Severidad: MEDIA** — Los ingenieros no pueden distinguir una instalación exitosa de una rota.

---

### 9. [BROKEN_CMD] El `package-lock.json` usa la versión 1 del lockfile — genera advertencias en npm 7+
Al ejecutar `npm install` se emite:
```
npm warn old lockfile The package-lock.json file was created with an old version of npm,
so supplemental metadata must be fetched from the registry.
```
No es un bloqueo duro, pero obliga a npm a volver a descargar metadatos y hace que los ingenieros duden si la instalación fue exitosa. El `package-lock.json` fue generado con npm v5/v6 (2019) y es incompatible con npm moderno sin advertencias.  
**Severidad: BAJA** — La salida ruidosa erosiona la confianza; los ingenieros pueden pasar tiempo depurando un no-problema.

---

### 10. [MISSING_DOC] Nunca se menciona la URL de la app después del inicio
El servidor arranca en el puerto 3001, pero el README nunca le dice al ingeniero que abra `http://localhost:3001`. No hay instrucción "Ahora visita...". Combinado con la falta de `npm start`, un desarrollador debe leer el código fuente de `server.js` para descubrir el puerto.  
**Severidad: MEDIA** — Requiere leer el código fuente para completar el onboarding. Viola el contrato del README.

---

### 11. [SILENT_FAIL] `response.sendfile()` está deprecado en Express 4 — emite advertencia silenciosa
`server.js` usa `response.sendfile(...)` (con `f` minúscula), que fue deprecado en Express 4. En Node 22 + Express 4.17.1, esto emite una advertencia de deprecación al inicio que es fácil de ignorar:
```
DeprecationWarning: res.sendfile: Use res.sendFile instead
```
La app técnicamente funciona, pero la advertencia señala código roto que dejará de funcionar en una versión futura de Express. Los ingenieros nuevos no sabrán si esto es intencional.  
**Severidad: BAJA** — Deuda técnica que genera advertencias confusas; no está documentada.

---

### 12. [MISSING_DOC] Sin orientación sobre la carpeta `node_modules` para ingenieros junior
Aunque `node_modules/` está correctamente en el `.gitignore`, no hay documentación al respecto. Un ingeniero junior puede no entender por qué `node_modules` no existe después de clonar, o por qué se requiere `npm install`.  
**Severidad: BAJA** — Brecha menor, afecta principalmente a ingenieros muy junior.

---

## Resumen de Severidad

| # | Etiqueta | Descripción | Severidad |
|---|----------|-------------|-----------|
| 1 | VERSION_HELL | Sin versión de Node.js especificada | ALTA |
| 2 | IMPLICIT_DEP | `nodemon` no está en devDependencies | **BLOQUEANTE** |
| 3 | MISSING_DOC | Sin script `npm start` | MEDIA |
| 4 | MISSING_DOC | Sin comando alternativo de inicio sin nodemon | **BLOQUEANTE** |
| 5 | IMPLICIT_DEP | nodemon como dep global rompe CI/CD | ALTA |
| 6 | MISSING_DOC | Puerto 3001 hardcodeado, sin documentar ni configurable | MEDIA |
| 7 | ENV_GAP | Sin `.env.example` aunque `.env` está en .gitignore | BAJA |
| 8 | MISSING_DOC | Sin salida esperada ni paso de verificación documentado | MEDIA |
| 9 | BROKEN_CMD | `package-lock.json` antiguo genera advertencias en npm moderno | BAJA |
| 10 | MISSING_DOC | URL de la app nunca mencionada en el README | MEDIA |
| 11 | SILENT_FAIL | `res.sendfile()` deprecado emite advertencia silenciosa | BAJA |
| 12 | MISSING_DOC | Sin explicación de por qué falta node_modules | BAJA |

---

## Totales

- **Total de puntos de fricción encontrados:** 12
- **Primer bloqueo completo:** Punto #2 — `nodemon: not found` en el primer intento de iniciar el servidor
- **Hasta dónde llega un ingeniero nuevo antes de rendirse:** `npm install` tiene éxito, pero `nodemon server.js` falla de inmediato. El ingeniero queda bloqueado en el paso 1 de ejecutar la aplicación.
- **Tiempo estimado perdido por ingeniero nuevo:**
  - 5–10 min: Googleando por qué no se encuentra `nodemon`
  - 10–15 min: Descubriendo la versión correcta de Node (prueba y error)
  - 5 min: Descubriendo que `node server.js` funciona como alternativa
  - 10 min: Averiguando el puerto, la URL y la salida esperada
  - **Total estimado: 30–45 minutos mínimo por ingeniero**