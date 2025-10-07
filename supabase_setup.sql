-- Script completo para configurar Supabase para Kaizeneka
-- Ejecuta este script en el SQL Editor de Supabase

-- ===========================================
-- CREAR TABLAS
-- ===========================================

-- Tabla: recursos
CREATE TABLE IF NOT EXISTS recursos (
  id SERIAL PRIMARY KEY,
  titulo TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('video', 'audio')),
  url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla: users (para datos de progreso de usuario)
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  belt TEXT NOT NULL DEFAULT 'Blanco',
  points INTEGER DEFAULT 0,
  dias_completados INTEGER DEFAULT 0,
  misiones_completadas INTEGER[] DEFAULT '{}',
  logros_desbloqueados TEXT[] DEFAULT '{}',
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla: posts
CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  usuario_nombre TEXT NOT NULL,
  usuario_cinturon TEXT NOT NULL,
  usuario_avatar TEXT,
  imagen_url TEXT,
  texto TEXT,
  likes INTEGER DEFAULT 0,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  liked_by_user BOOLEAN DEFAULT FALSE
);

-- ===========================================
-- CONFIGURAR PERMISOS (RLS)
-- ===========================================

-- Habilitar RLS para recursos
ALTER TABLE recursos ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública de recursos
DROP POLICY IF EXISTS "Recursos are viewable by everyone" ON recursos;
CREATE POLICY "Recursos are viewable by everyone" ON recursos
FOR SELECT USING (true);

-- Política para inserción de recursos (solo usuarios autenticados)
DROP POLICY IF EXISTS "Recursos are insertable by authenticated users" ON recursos;
CREATE POLICY "Recursos are insertable by authenticated users" ON recursos
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Habilitar RLS para posts
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública de posts
DROP POLICY IF EXISTS "Posts are viewable by everyone" ON posts;
CREATE POLICY "Posts are viewable by everyone" ON posts
FOR SELECT USING (true);

-- Política para inserción de posts (usuarios autenticados)
DROP POLICY IF EXISTS "Posts are insertable by authenticated users" ON posts;
CREATE POLICY "Posts are insertable by authenticated users" ON posts
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para actualización de posts (solo el autor)
DROP POLICY IF EXISTS "Posts are updatable by owner" ON posts;
CREATE POLICY "Posts are updatable by owner" ON posts
FOR UPDATE USING (auth.uid() = user_id OR auth.role() = 'admin');

-- Habilitar RLS para users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Política para lectura de users (solo el propio usuario)
DROP POLICY IF EXISTS "Users can view own profile" ON users;
CREATE POLICY "Users can view own profile" ON users
FOR SELECT USING (auth.uid() = id);

-- Política para inserción de users (solo usuarios autenticados para su propio perfil)
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile" ON users
FOR INSERT WITH CHECK (auth.uid() = id);

-- Política para actualización de users (solo el propio usuario)
DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile" ON users
FOR UPDATE USING (auth.uid() = id);

-- ===========================================
-- CREAR FUNCIÓN RPC PARA LIKES
-- ===========================================

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

-- ===========================================
-- ACTUALIZAR TABLA USERS (si ya existe)
-- ===========================================

-- Agregar columnas si no existen
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS dias_completados INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS misiones_completadas INTEGER[] DEFAULT '{}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS logros_desbloqueados TEXT[] DEFAULT '{}';

-- ===========================================
-- INSERTAR DATOS DE PRUEBA
-- ===========================================

-- Limpiar datos existentes (opcional)
-- TRUNCATE TABLE recursos, posts RESTART IDENTITY;

-- Insertar recursos de ejemplo
INSERT INTO recursos (titulo, tipo, url) VALUES
('Introducción a la Meditación', 'video', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
('Música para Relajación', 'audio', 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'),
('Técnicas de Respiración', 'video', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
('Meditación Guiada - 10 minutos', 'audio', 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav')
ON CONFLICT DO NOTHING;

-- Insertar posts de ejemplo
INSERT INTO posts (usuario_nombre, usuario_cinturon, usuario_avatar, imagen_url, texto, likes, timestamp, liked_by_user) VALUES
('Pedro', 'Verde', NULL, 'https://via.placeholder.com/300x200?text=Entrenando', NULL, 15, NOW() - INTERVAL '2 hours', FALSE),
('Ana', 'Negro', NULL, NULL, 'Hoy lucrando solecito 🌞', 8, NOW() - INTERVAL '4 hours', TRUE),
('Carlos', 'Marrón', NULL, 'https://via.placeholder.com/300x200?text=Comiendo+sano', NULL, 22, NOW() - INTERVAL '6 hours', FALSE),
('María', 'Azul', NULL, NULL, '¡Nueva sesión de entrenamiento completada! 💪', 12, NOW() - INTERVAL '8 hours', FALSE),
('Luis', 'Amarillo', NULL, 'https://via.placeholder.com/300x200?text=Descanso', 'Día de recuperación activa', 5, NOW() - INTERVAL '12 hours', TRUE)
ON CONFLICT DO NOTHING;

-- ===========================================
-- VERIFICAR CONFIGURACIÓN
-- ===========================================

-- Mostrar resumen de tablas
SELECT 'recursos' as tabla, COUNT(*) as registros FROM recursos
UNION ALL
SELECT 'posts' as tabla, COUNT(*) as registros FROM posts
UNION ALL
SELECT 'users' as tabla, COUNT(*) as registros FROM users;

-- Verificar que las políticas están activas
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('recursos', 'posts', 'users')
AND schemaname = 'public';