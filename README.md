# Reloj de Turnos

App instalable (PWA) para marcar entrada y salida del trabajo remoto, ver las horas del período de pago (lunes 4:00 PM a lunes 3:59 PM) contra la meta de 64 h, calcular lo que llega por PayPal en pesos y dólares, y llevar un registro de estudio por materia. Los datos viven en Supabase y se sincronizan entre el celular y la computadora; sin internet se guardan en el teléfono y se suben después.

## 1. Supabase

1. Crea un proyecto en https://supabase.com (plan gratis).
2. **SQL Editor → New query**, pega el contenido de `schema.sql` y dale **Run**. Crea las tablas `shifts`, `study` y `settings`, con reglas para que cada cuenta vea solo lo suyo y con sincronización en vivo.
3. **Project Settings → API**: copia la **Project URL** y la clave **anon public** y pégalas en `config.js`.
4. **Authentication → URL Configuration**: pon como Site URL el link de GitHub Pages (paso 2).
5. Después de crear tu cuenta en la app, puedes desactivar registros nuevos en **Authentication → Sign In / Providers → Allow new users to sign up** para que nadie más se pueda registrar.

Si quieres entrar sin confirmar el correo, desactiva **Confirm email** en Authentication → Sign In / Providers → Email.

## 2. GitHub Pages

1. Sube todos los archivos a la raíz del repositorio.
2. **Settings → Pages → Deploy from a branch**, rama `main`, carpeta `/ (root)`.
3. Queda en `https://<usuario>.github.io/<repo>/`.

## 3. Instalarla en el celular

- **Android (Chrome):** abre el link → menú ⋮ → **Instalar app**.
- **iPhone (Safari):** abre el link → **Compartir** → **Agregar a pantalla de inicio**.

## Archivos

| Archivo | Para qué |
|---|---|
| `index.html` | La app completa |
| `config.js` | URL y clave anon de Supabase |
| `schema.sql` | Tablas y reglas de seguridad |
| `sw.js` | Hace que funcione sin internet |
| `manifest.webmanifest`, `icons/` | Ícono y modo app |

La clave anon es pública por diseño: lo que protege los datos son las reglas RLS de `schema.sql`. Nunca pongas la clave `service_role` en `config.js`.
