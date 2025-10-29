-- Migración para agregar campos de progreso al sistema Kaizeneka
-- Ejecutar después de la configuración inicial de Supabase

-- Agregar campos de progreso a la tabla users
ALTER TABLE users ADD COLUMN IF NOT EXISTS xp INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS coins INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1;
ALTER TABLE users ADD COLUMN IF NOT EXISTS streak INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS energy INTEGER DEFAULT 100;
ALTER TABLE users ADD COLUMN IF NOT EXISTS jvc_progress JSONB DEFAULT '{"Salud": 0, "Dinámicas Sociales": 0, "Psicología del Éxito": 0}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS current_world TEXT DEFAULT 'Salud Extrema';
ALTER TABLE users ADD COLUMN IF NOT EXISTS current_arc INTEGER DEFAULT 1;
ALTER TABLE users ADD COLUMN IF NOT EXISTS unlocked_missions JSONB DEFAULT '[]';
ALTER TABLE users ADD COLUMN IF NOT EXISTS unlocked_achievements JSONB DEFAULT '[]';
ALTER TABLE users ADD COLUMN IF NOT EXISTS stats JSONB DEFAULT '{"fuerza": 0, "constancia": 0, "foco": 0}';

-- Agregar campos adicionales para compatibilidad
ALTER TABLE users ADD COLUMN IF NOT EXISTS dias_completados INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS misiones_completadas JSONB DEFAULT '[]';
ALTER TABLE users ADD COLUMN IF NOT EXISTS logros_desbloqueados JSONB DEFAULT '[]';

-- Crear tabla para misiones narrativas
CREATE TABLE IF NOT EXISTS narrative_missions (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  principle TEXT NOT NULL,
  arc TEXT NOT NULL,
  phase INTEGER NOT NULL,
  order_index INTEGER NOT NULL,
  difficulty TEXT NOT NULL,
  xp_reward INTEGER NOT NULL,
  coins_reward INTEGER NOT NULL,
  tags JSONB DEFAULT '[]',
  is_unlocked BOOLEAN DEFAULT FALSE,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla para logros
CREATE TABLE IF NOT EXISTS achievements (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  conditions JSONB NOT NULL,
  rewards JSONB NOT NULL,
  is_unlocked BOOLEAN DEFAULT FALSE,
  unlocked_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla para hábitos con progreso
CREATE TABLE IF NOT EXISTS habits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT,
  difficulty TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  repeat_type TEXT NOT NULL,
  completed_dates JSONB DEFAULT '[]',
  streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla para tareas con progreso
CREATE TABLE IF NOT EXISTS tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT,
  difficulty TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  repeat_type TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  sub_tasks JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Crear tabla para misiones con progreso
CREATE TABLE IF NOT EXISTS missions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT,
  difficulty TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  repeat_type TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  points INTEGER NOT NULL,
  sub_missions JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Políticas RLS para nuevas tablas

-- narrative_missions: lectura pública, escritura admin
ALTER TABLE narrative_missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Narrative missions are viewable by everyone" ON narrative_missions
FOR SELECT USING (true);

-- achievements: lectura por usuario, escritura admin
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Achievements are viewable by everyone" ON achievements
FOR SELECT USING (true);

-- habits: solo el propietario
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habits" ON habits
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits" ON habits
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits" ON habits
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits" ON habits
FOR DELETE USING (auth.uid() = user_id);

-- tasks: solo el propietario
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tasks" ON tasks
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON tasks
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON tasks
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON tasks
FOR DELETE USING (auth.uid() = user_id);

-- missions: solo el propietario
ALTER TABLE missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own missions" ON missions
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own missions" ON missions
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own missions" ON missions
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own missions" ON missions
FOR DELETE USING (auth.uid() = user_id);

-- Insertar misiones narrativas de ejemplo (primeras 10)
INSERT INTO narrative_missions (id, title, description, principle, arc, phase, order_index, difficulty, xp_reward, coins_reward, tags) VALUES
('despertar_1', 'Identifica tus 3 RDPs más obvias', 'Reconoce tus Rendijas de Palme más evidentes que te roban tiempo y energía.', 'Conciencia del Palme', 'despertar', 1, 1, 'medium', 15, 3, '["autodiagnóstico", "conciencia"]'),
('despertar_2', 'Desinstala una app de palme', 'Elimina una aplicación que sabes que te distrae innecesariamente.', 'Conciencia del Palme', 'despertar', 1, 2, 'easy', 10, 2, '["desintoxicación", "acción"]'),
('despertar_3', 'Crea tu "Declaración Antipalme"', 'Escribe una declaración personal contra el palme y tu compromiso con el cambio.', 'Conciencia del Palme', 'despertar', 1, 3, 'medium', 15, 3, '["compromiso", "escritura"]'),
('despertar_4', 'Día sin quejarte ni justificarte', 'Pasa un día completo aceptando las situaciones sin quejas ni excusas.', 'Autoobservación', 'despertar', 1, 4, 'hard', 25, 5, '["disciplina", "aceptación"]'),
('despertar_5', 'Limpieza simbólica de tu entorno', 'Limpia y organiza tu espacio físico como metáfora de limpieza mental.', 'Autoobservación', 'despertar', 1, 5, 'medium', 15, 3, '["limpieza", "simbólico"]'),
('despertar_6', 'Observa un pensamiento sin juzgarlo', 'Durante 10 minutos, observa tus pensamientos como un espectador neutral.', 'Autoobservación', 'despertar', 1, 6, 'medium', 15, 3, '["meditación", "conciencia"]'),
('despertar_7', 'Crea tu mapa de energía semanal', 'Registra tus niveles de energía hora por hora durante una semana.', 'Autoobservación', 'despertar', 1, 7, 'medium', 20, 4, '["registro", "energía"]'),
('despertar_8', 'Registra tus hábitos PPM', 'Identifica y registra tus hábitos de Palme Por Minuto.', 'Autoobservación', 'despertar', 1, 8, 'easy', 10, 2, '["registro", "hábitos"]'),
('despertar_9', 'Mide tu tiempo real de ocio improductivo', 'Cronometra exactamente cuánto tiempo dedicas al ocio que no te nutre.', 'Autoobservación', 'despertar', 1, 9, 'medium', 15, 3, '["medición", "conciencia"]'),
('despertar_10', 'Escoge tu mentor o guía', 'Selecciona una figura inspiradora que te guíe en tu camino Kaizeneka.', 'Autoobservación', 'despertar', 1, 10, 'easy', 10, 2, '["mentoría", "inspiración"]')
ON CONFLICT (id) DO NOTHING;

-- Insertar logros de ejemplo
INSERT INTO achievements (id, name, description, icon, conditions, rewards) VALUES
('first_task', 'Comienzo Épico', 'Completa tu primera tarea', '🎯', '{"completed_tasks": 1}', '{"xp": 5, "coins": 1}'),
('first_habit', 'Hábito Formado', 'Mantén un hábito por 3 días', '🔥', '{"habit_streak": 3}', '{"xp": 10, "coins": 2}'),
('level_up', 'Ascendido', 'Alcanza el nivel 2', '⬆️', '{"level": 2}', '{"xp": 25, "coins": 5}'),
('streak_master', 'Maestro de Rachas', 'Mantén una racha de 7 días', '⚡', '{"streak": 7}', '{"xp": 50, "coins": 10}'),
('mission_complete', 'Misionero', 'Completa tu primera misión narrativa', '📜', '{"completed_missions": 1}', '{"xp": 30, "coins": 6}'),
('balance_achieved', 'Equilibrio Perfecto', 'Alcanza 80% en las 3 JVCs', '⚖️', '{"jvc_balance": 80}', '{"xp": 100, "coins": 20}')
ON CONFLICT (id) DO NOTHING;

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_missions_user_id ON missions(user_id);
CREATE INDEX IF NOT EXISTS idx_narrative_missions_arc ON narrative_missions(arc);
CREATE INDEX IF NOT EXISTS idx_narrative_missions_phase ON narrative_missions(phase);

-- Función para calcular nivel desde XP
CREATE OR REPLACE FUNCTION calculate_level_from_xp(xp_amount INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    level INTEGER := 1;
    required_xp INTEGER;
BEGIN
    LOOP
        required_xp := level * 50 + (level * level) * 10;
        IF xp_amount < required_xp THEN
            RETURN level - 1;
        END IF;
        level := level + 1;
    END LOOP;
END;
$$;

-- Función para verificar si un usuario puede subir de nivel
CREATE OR REPLACE FUNCTION can_level_up(user_xp INTEGER, user_level INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    required_xp INTEGER;
BEGIN
    required_xp := user_level * 50 + (user_level * user_level) * 10;
    RETURN user_xp >= required_xp;
END;
$$;

-- Trigger para actualizar nivel automáticamente cuando cambia XP
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.xp != OLD.xp THEN
        NEW.level := calculate_level_from_xp(NEW.xp);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_user_level
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_user_level();

-- Función para otorgar recompensas por completar tareas
CREATE OR REPLACE FUNCTION grant_task_completion_rewards(
    p_user_id UUID,
    p_difficulty TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    xp_reward INTEGER;
    coins_reward INTEGER;
BEGIN
    -- Calcular recompensas basadas en dificultad
    CASE p_difficulty
        WHEN 'easy' THEN
            xp_reward := 5;
            coins_reward := 1;
        WHEN 'medium' THEN
            xp_reward := 10;
            coins_reward := 2;
        WHEN 'hard' THEN
            xp_reward := 20;
            coins_reward := 4;
        ELSE
            xp_reward := 10;
            coins_reward := 2;
    END CASE;

    -- Actualizar usuario
    UPDATE users
    SET
        xp = xp + xp_reward,
        coins = coins + coins_reward,
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;

-- Función para otorgar recompensas por completar hábitos
CREATE OR REPLACE FUNCTION grant_habit_completion_rewards(
    p_user_id UUID,
    p_difficulty TEXT,
    p_streak INTEGER
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    base_xp INTEGER;
    base_coins INTEGER;
    streak_bonus INTEGER;
BEGIN
    -- Calcular recompensas base
    CASE p_difficulty
        WHEN 'easy' THEN
            base_xp := 3;
            base_coins := 1;
        WHEN 'medium' THEN
            base_xp := 5;
            base_coins := 2;
        WHEN 'hard' THEN
            base_xp := 8;
            base_coins := 3;
        ELSE
            base_xp := 5;
            base_coins := 2;
    END CASE;

    -- Bonificación por racha (cada 5 días)
    streak_bonus := (p_streak / 5) * base_coins;

    -- Actualizar usuario
    UPDATE users
    SET
        xp = xp + base_xp,
        coins = coins + base_coins + streak_bonus,
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;

-- Función para actualizar progreso JVC
CREATE OR REPLACE FUNCTION update_jvc_progress(
    p_user_id UUID,
    p_jvc_area TEXT,
    p_progress_change INTEGER
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    current_progress INTEGER;
BEGIN
    -- Obtener progreso actual
    SELECT (jvc_progress->>p_jvc_area)::INTEGER INTO current_progress
    FROM users
    WHERE id = p_user_id;

    -- Actualizar progreso (mantener entre 0 y 100)
    UPDATE users
    SET
        jvc_progress = jsonb_set(
            jvc_progress,
            ARRAY[p_jvc_area],
            to_jsonb(GREATEST(0, LEAST(100, current_progress + p_progress_change)))
        ),
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;