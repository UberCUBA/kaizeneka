# Configuración de Supabase para Kaizeneka

## Paso 1: Obtener las credenciales de Supabase

1. Ve a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. Ve a **Settings > API**
3. Copia:
   - **Project URL**
   - **anon/public key**

4. Actualiza `lib/core/services/supabase_service.dart`:
```dart
static const String supabaseUrl = 'TU_PROJECT_URL_AQUI';
static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';
```

## Paso 2: Crear las tablas

### Tabla: `recursos`

```sql
CREATE TABLE recursos (
  id SERIAL PRIMARY KEY,
  titulo TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('video', 'audio')),
  url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Datos de ejemplo:**
```sql
INSERT INTO recursos (titulo, tipo, url) VALUES
('Introducción a la Meditación', 'video', 'https://example.com/video1.mp4'),
('Música para Relajación', 'audio', 'https://example.com/audio1.mp3'),
('Técnicas de Respiración', 'video', 'https://example.com/video2.mp4');
```

### Tabla: `posts`

```sql
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  usuario_nombre TEXT NOT NULL,
  usuario_cinturon TEXT NOT NULL,
  usuario_avatar TEXT,
  imagen_url TEXT,
  texto TEXT,
  likes INTEGER DEFAULT 0,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  liked_by_user BOOLEAN DEFAULT FALSE
);
```

**Datos de ejemplo:**
```sql
INSERT INTO posts (usuario_nombre, usuario_cinturon, usuario_avatar, imagen_url, texto, likes, timestamp, liked_by_user) VALUES
('Pedro', 'Verde', NULL, 'https://via.placeholder.com/300x200?text=Entrenando', NULL, 15, NOW() - INTERVAL '2 hours', FALSE),
('Ana', 'Negro', NULL, NULL, 'Hoy lucrando solecito 🌞', 8, NOW() - INTERVAL '4 hours', TRUE),
('Carlos', 'Marrón', NULL, 'https://via.placeholder.com/300x200?text=Comiendo+sano', NULL, 22, NOW() - INTERVAL '6 hours', FALSE);
```

## Paso 3: Configurar Row Level Security (RLS)

### Para tabla `recursos`:
```sql
-- Habilitar RLS
ALTER TABLE recursos ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública
CREATE POLICY "Recursos are viewable by everyone" ON recursos
FOR SELECT USING (true);

-- Política para inserción (solo admin - ajusta según necesites)
CREATE POLICY "Recursos are insertable by authenticated users" ON recursos
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### Para tabla `posts`:
```sql
-- Habilitar RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública
CREATE POLICY "Posts are viewable by everyone" ON posts
FOR SELECT USING (true);

-- Política para inserción (todos los usuarios autenticados)
CREATE POLICY "Posts are insertable by authenticated users" ON posts
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para actualización (solo el autor o admin)
CREATE POLICY "Posts are updatable by owner" ON posts
FOR UPDATE USING (auth.uid()::text = usuario_nombre OR auth.role() = 'admin');
```

## Paso 4: Crear función RPC para likes

```sql
CREATE OR REPLACE FUNCTION increment_likes(post_id INTEGER)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE posts
  SET likes = likes + 1
  WHERE id = post_id;
END;
$$;
```

## Paso 5: Verificar la configuración

1. Ve a **Table Editor** en Supabase Dashboard
2. Verifica que las tablas `recursos` y `posts` existan con los campos correctos
3. Ve a **SQL Editor** y ejecuta consultas de prueba:
```sql
-- Probar recursos
SELECT * FROM recursos;

-- Probar posts
SELECT * FROM posts ORDER BY timestamp DESC;

-- Probar función RPC
SELECT increment_likes(1);
```

## Paso 6: Configuración adicional (opcional)

### Autenticación
Para configurar autenticación con Google:

1. Ve a **Authentication > Providers** en Supabase Dashboard
2. Habilita **Google** como proveedor
3. Necesitas configurar un proyecto en Google Cloud Console:
   - Ve a [Google Cloud Console](https://console.cloud.google.com/)
   - Crea un nuevo proyecto o selecciona uno existente
   - Habilita la API de Google+ API
   - Crea credenciales OAuth 2.0 (ID de cliente y secreto)
   - Agrega las URLs de redireccionamiento autorizadas:
     - Para web: `https://aipsndkhriquaqddmeyj.supabase.co/auth/v1/callback`
     - Para móvil: configura según tu app
4. Copia el Client ID y Client Secret a Supabase
5. En la app Flutter, agrega el paquete `google_sign_in` y configura

### Tabla de usuarios para progreso
Se ha agregado una tabla `users` para almacenar datos de progreso:

```sql
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  belt TEXT NOT NULL DEFAULT 'Blanco',
  points INTEGER DEFAULT 0,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Políticas RLS:**
- Los usuarios solo pueden ver/editar su propio perfil
- Se requiere autenticación para acceder a datos de usuario

### Storage (para imágenes)
Si necesitas subir imágenes:
1. Ve a **Storage** en Supabase Dashboard
2. Crea un bucket llamado `avatars` o `posts-images`
3. Configura políticas de acceso

## Problemas comunes

1. **Error de conexión**: Verifica que las URL y keys en `supabase_service.dart` sean correctas
2. **Permisos insuficientes**: Revisa las políticas RLS
3. **Función RPC no encontrada**: Asegúrate de crear la función `increment_likes`
4. **Datos no aparecen**: Verifica que los nombres de tabla y campos coincidan exactamente

## Testing

Una vez configurado, ejecuta la app y verifica:
- ✅ La app se inicia sin errores
- ✅ Los recursos se cargan en la biblioteca
- ✅ Los posts se muestran en postureo
- ✅ El contador de likes funciona