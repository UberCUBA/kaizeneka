-- =========================================
-- SUPABASE SETUP FOR NK+ TASK MANAGEMENT
-- =========================================

-- Enable Row Level Security (RLS) on all tables
-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================
-- USERS TABLE (extends auth.users) - SISTEMA DE PROGRESIÓN NK
-- =========================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    belt TEXT DEFAULT 'Blanco', -- Ahora representa el nivel (Blanco, Amarillo, etc.)
    points INTEGER DEFAULT 0, -- Puntos unificados (antes xp + points)
    dias_completados INTEGER DEFAULT 0,
    misiones_completadas TEXT[] DEFAULT '{}',
    logros_desbloqueados TEXT[] DEFAULT '{}',
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    avatar_url TEXT,
    -- Sistema de Progresión NK Unificado
    coins INTEGER DEFAULT 0, -- Moneda para compras futuras
    streak INTEGER DEFAULT 0, -- Racha diaria
    energy INTEGER DEFAULT 100, -- Energía disponible
    jvc_progress JSONB DEFAULT '{"Salud": 0, "Dinámicas Sociales": 0, "Psicología del Éxito": 0}',
    current_world TEXT DEFAULT 'Salud Extrema',
    current_arc INTEGER DEFAULT 1,
    unlocked_missions TEXT[] DEFAULT '{}',
    unlocked_achievements TEXT[] DEFAULT '{}',
    stats JSONB DEFAULT '{"fuerza": 0, "constancia": 0, "foco": 0}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =========================================
-- TASKS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    repeat_type TEXT CHECK (repeat_type IN ('daily', 'weekly', 'monthly')),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tasks table
CREATE POLICY "Users can view their own tasks" ON public.tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tasks" ON public.tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tasks" ON public.tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tasks" ON public.tasks
    FOR DELETE USING (auth.uid() = user_id);

-- =========================================
-- SUBTASKS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS public.subtasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;

-- RLS Policies for subtasks table
CREATE POLICY "Users can view subtasks of their tasks" ON public.subtasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert subtasks for their tasks" ON public.subtasks
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update subtasks of their tasks" ON public.subtasks
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete subtasks of their tasks" ON public.subtasks
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- =========================================
-- MISSIONS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS public.missions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    repeat_type TEXT CHECK (repeat_type IN ('daily', 'weekly', 'monthly')),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    points INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for missions table
CREATE POLICY "Users can view their own missions" ON public.missions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own missions" ON public.missions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own missions" ON public.missions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own missions" ON public.missions
    FOR DELETE USING (auth.uid() = user_id);

-- =========================================
-- SUBMISSIONS TABLE (SubMissions)
-- =========================================
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    points INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for submissions table
CREATE POLICY "Users can view submissions of their missions" ON public.submissions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.missions
            WHERE missions.id = submissions.mission_id
            AND missions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert submissions for their missions" ON public.submissions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.missions
            WHERE missions.id = submissions.mission_id
            AND missions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update submissions of their missions" ON public.submissions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.missions
            WHERE missions.id = submissions.mission_id
            AND missions.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete submissions of their missions" ON public.submissions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.missions
            WHERE missions.id = submissions.mission_id
            AND missions.user_id = auth.uid()
        )
    );

-- =========================================
-- HABITS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    repeat_type TEXT CHECK (repeat_type IN ('daily', 'weekly', 'monthly')) DEFAULT 'daily' NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    completed_dates TIMESTAMP WITH TIME ZONE[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

-- RLS Policies for habits table
CREATE POLICY "Users can view their own habits" ON public.habits
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own habits" ON public.habits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own habits" ON public.habits
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habits" ON public.habits
    FOR DELETE USING (auth.uid() = user_id);

-- =========================================
-- NARRATIVE MISSIONS SYSTEM - 210 MISIONES NK
-- =========================================

-- Narrative Missions Table
CREATE TABLE IF NOT EXISTS public.narrative_missions (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    principle TEXT NOT NULL,
    arc TEXT CHECK (arc IN ('despertar', 'entrenamiento', 'disciplina', 'sinergia', 'disolucion', 'sobradez', 'trascendencia')) NOT NULL,
    phase INTEGER CHECK (phase >= 1 AND phase <= 7) NOT NULL,
    order_in_phase INTEGER NOT NULL,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    xp_reward INTEGER DEFAULT 0,
    coins_reward INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(arc, phase, order_in_phase)
);

-- Achievements Table
CREATE TABLE IF NOT EXISTS public.achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    conditions JSONB NOT NULL,
    rewards JSONB NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- User Narrative Progress
CREATE TABLE IF NOT EXISTS public.user_narrative_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    mission_id TEXT REFERENCES public.narrative_missions(id) ON DELETE CASCADE NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, mission_id)
);

-- User Achievements Progress
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    achievement_id TEXT REFERENCES public.achievements(id) ON DELETE CASCADE NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, achievement_id)
);

-- Enable RLS for narrative system
ALTER TABLE public.narrative_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_narrative_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for narrative missions (public read for active missions)
CREATE POLICY "Users can view active narrative missions" ON public.narrative_missions
    FOR SELECT USING (is_active = true);

-- RLS Policies for achievements (public read for active achievements)
CREATE POLICY "Users can view active achievements" ON public.achievements
    FOR SELECT USING (is_active = true);

-- RLS Policies for user narrative progress
CREATE POLICY "Users can view their own narrative progress" ON public.user_narrative_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own narrative progress" ON public.user_narrative_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own narrative progress" ON public.user_narrative_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for user achievements
CREATE POLICY "Users can view their own achievements" ON public.user_achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own achievements" ON public.user_achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own achievements" ON public.user_achievements
    FOR UPDATE USING (auth.uid() = user_id);

-- =========================================
-- PREDEFINED CONTENT TABLES
-- =========================================

-- Predefined Tasks
CREATE TABLE IF NOT EXISTS public.predefined_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    category TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Predefined Missions
CREATE TABLE IF NOT EXISTS public.predefined_missions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    points INTEGER DEFAULT 0,
    category TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Predefined Habits
CREATE TABLE IF NOT EXISTS public.predefined_habits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    repeat_type TEXT CHECK (repeat_type IN ('daily', 'weekly', 'monthly')) DEFAULT 'daily',
    category TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS for predefined content (public read access)
ALTER TABLE public.predefined_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.predefined_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.predefined_habits ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read predefined content
CREATE POLICY "Authenticated users can view predefined tasks" ON public.predefined_tasks
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view predefined missions" ON public.predefined_missions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view predefined habits" ON public.predefined_habits
    FOR SELECT USING (auth.role() = 'authenticated');

-- =========================================
-- SHARED CONTENT TABLES
-- =========================================

-- Shared Tasks
CREATE TABLE IF NOT EXISTS public.shared_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    original_task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    share_code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    category TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Shared Missions
CREATE TABLE IF NOT EXISTS public.shared_missions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    original_mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    share_code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    points INTEGER DEFAULT 0,
    category TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS for shared content
ALTER TABLE public.shared_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_missions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for shared content
CREATE POLICY "Users can view shared tasks" ON public.shared_tasks
    FOR SELECT USING (true); -- Public read access for sharing

CREATE POLICY "Users can create shared tasks from their own" ON public.shared_tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view shared missions" ON public.shared_missions
    FOR SELECT USING (true); -- Public read access for sharing

CREATE POLICY "Users can create shared missions from their own" ON public.shared_missions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =========================================
-- INDEXES FOR PERFORMANCE
-- =========================================

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_belt ON public.users(belt);
CREATE INDEX IF NOT EXISTS idx_users_points ON public.users(points DESC);
CREATE INDEX IF NOT EXISTS idx_users_xp ON public.users(xp DESC);
CREATE INDEX IF NOT EXISTS idx_users_level ON public.users(level DESC);
CREATE INDEX IF NOT EXISTS idx_users_current_arc ON public.users(current_arc);

-- Narrative system indexes
CREATE INDEX IF NOT EXISTS idx_narrative_missions_arc_phase ON public.narrative_missions(arc, phase);
CREATE INDEX IF NOT EXISTS idx_narrative_missions_active ON public.narrative_missions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_narrative_progress_user ON public.user_narrative_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_narrative_progress_mission ON public.user_narrative_progress(mission_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON public.user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_achievements_active ON public.achievements(is_active);

-- Tasks table indexes
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_completed ON public.tasks(is_completed);
CREATE INDEX IF NOT EXISTS idx_tasks_start_date ON public.tasks(start_date);

-- Missions table indexes
CREATE INDEX IF NOT EXISTS idx_missions_user_id ON public.missions(user_id);
CREATE INDEX IF NOT EXISTS idx_missions_completed ON public.missions(is_completed);
CREATE INDEX IF NOT EXISTS idx_missions_start_date ON public.missions(start_date);

-- Habits table indexes
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_streak ON public.habits(streak DESC);

-- Shared content indexes
CREATE INDEX IF NOT EXISTS idx_shared_tasks_code ON public.shared_tasks(share_code);
CREATE INDEX IF NOT EXISTS idx_shared_missions_code ON public.shared_missions(share_code);

-- =========================================
-- FUNCTIONS AND TRIGGERS
-- =========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_narrative_progress_updated_at BEFORE UPDATE ON public.user_narrative_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subtasks_updated_at BEFORE UPDATE ON public.subtasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at BEFORE UPDATE ON public.missions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_submissions_updated_at BEFORE UPDATE ON public.submissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =========================================
-- NARRATIVE MISSIONS DATA - 210 MISIONES NK
-- =========================================

-- FASE 1 – EL DESPERTAR (Arco 1) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('despertar_1', 'Identifica tus 3 RDPs más obvias', 'Reconoce tus Rendijas de Palme más evidentes que te roban tiempo y energía.', 'Conciencia del Palme', 'despertar', 1, 1, 'medium', 15, 3, ARRAY['autodiagnóstico', 'conciencia']),
('despertar_2', 'Desinstala una app de palme', 'Elimina una aplicación que sabes que te distrae innecesariamente.', 'Conciencia del Palme', 'despertar', 1, 2, 'easy', 10, 2, ARRAY['desintoxicación', 'acción']),
('despertar_3', 'Crea tu "Declaración Antipalme"', 'Escribe una declaración personal contra el palme y tu compromiso con el cambio.', 'Conciencia del Palme', 'despertar', 1, 3, 'medium', 15, 3, ARRAY['compromiso', 'escritura']),
('despertar_4', 'Día sin quejarte ni justificarte', 'Pasa un día completo aceptando las situaciones sin quejas ni excusas.', 'Autoobservación', 'despertar', 1, 4, 'hard', 25, 5, ARRAY['disciplina', 'aceptación']),
('despertar_5', 'Limpieza simbólica de tu entorno', 'Limpia y organiza tu espacio físico como metáfora de limpieza mental.', 'Autoobservación', 'despertar', 1, 5, 'medium', 15, 3, ARRAY['limpieza', 'simbólico']),
('despertar_6', 'Observa un pensamiento sin juzgarlo', 'Durante 10 minutos, observa tus pensamientos como un espectador neutral.', 'Autoobservación', 'despertar', 1, 6, 'medium', 15, 3, ARRAY['meditación', 'conciencia']),
('despertar_7', 'Crea tu mapa de energía semanal', 'Registra tus niveles de energía hora por hora durante una semana.', 'Autoobservación', 'despertar', 1, 7, 'medium', 20, 4, ARRAY['registro', 'energía']),
('despertar_8', 'Registra tus hábitos PPM', 'Identifica y registra tus hábitos de Palme Por Minuto.', 'Autoobservación', 'despertar', 1, 8, 'easy', 10, 2, ARRAY['registro', 'hábitos']),
('despertar_9', 'Mide tu tiempo real de ocio improductivo', 'Cronometra exactamente cuánto tiempo dedicas al ocio que no te nutre.', 'Autoobservación', 'despertar', 1, 9, 'medium', 15, 3, ARRAY['medición', 'conciencia']),
('despertar_10', 'Escoge tu mentor o guía', 'Selecciona una figura inspiradora que te guíe en tu camino Kaizeneka.', 'Autoobservación', 'despertar', 1, 10, 'easy', 10, 2, ARRAY['mentoría', 'inspiración']);

-- FASE 2 – ENTRENAMIENTO (Arco 2) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('entrenamiento_1', 'Define tus OVCs personales', 'Establece tus Objetivos Vitales Clave para las próximas semanas.', 'Disciplina y energía', 'entrenamiento', 2, 1, 'medium', 20, 4, ARRAY['planificación', 'objetivos']),
('entrenamiento_2', 'Optimiza tu mañana', 'Crea una rutina matinal de 30 minutos que te prepare para el día.', 'Disciplina y energía', 'entrenamiento', 2, 2, 'medium', 20, 4, ARRAY['rutina', 'mañana']),
('entrenamiento_3', 'Mantén 3 hábitos saludables una semana', 'Establece y mantén tres hábitos positivos durante 7 días consecutivos.', 'Disciplina y energía', 'entrenamiento', 2, 3, 'hard', 30, 6, ARRAY['hábitos', 'consistencia']),
('entrenamiento_4', 'Una semana sin multitarea', 'Dedícate completamente a una tarea a la vez durante 7 días.', 'Disciplina y energía', 'entrenamiento', 2, 4, 'hard', 30, 6, ARRAY['enfoque', 'productividad']),
('entrenamiento_5', 'Activa "Ganasolina Full Tank"', 'Realiza actividades que recarguen completamente tu energía vital.', 'Disciplina y energía', 'entrenamiento', 2, 5, 'medium', 20, 4, ARRAY['energía', 'recarga']),
('entrenamiento_6', 'Aprende a decir "no" sin culpa', 'Practica rechazar compromisos que no aporten valor a tu vida.', 'Disciplina y energía', 'entrenamiento', 2, 6, 'medium', 20, 4, ARRAY['límites', 'autoconfianza']),
('entrenamiento_7', 'Mide tu productividad real', 'Registra y analiza tu tiempo productivo vs tiempo total disponible.', 'Disciplina y energía', 'entrenamiento', 2, 7, 'medium', 20, 4, ARRAY['medición', 'productividad']),
('entrenamiento_8', 'Registra tus victorias diarias', 'Cada noche, anota 3 cosas positivas que lograste ese día.', 'Disciplina y energía', 'entrenamiento', 2, 8, 'easy', 10, 2, ARRAY['gratitud', 'registro']),
('entrenamiento_9', 'Mantén tu energía en balance 3 días', 'Equilibra alimentación, ejercicio y descanso durante 72 horas.', 'Disciplina y energía', 'entrenamiento', 2, 9, 'hard', 30, 6, ARRAY['equilibrio', 'energía']),
('entrenamiento_10', 'Reto: Dormir 8h tres noches seguidas', 'Consigue dormir 8 horas completas durante 3 noches consecutivas.', 'Disciplina y energía', 'entrenamiento', 2, 10, 'hard', 35, 7, ARRAY['sueño', 'disciplina']);

-- FASE 3 – DISCIPLINA (Arcos 3 y 7) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('disciplina_1', 'Diseña tu rutina NK personalizada', 'Crea una rutina completa basada en los principios Kaizeneka.', 'Autodominio físico y mental', 'disciplina', 3, 1, 'hard', 35, 7, ARRAY['rutina', 'personalización']),
('disciplina_2', 'Mantén una racha de 14 días', 'Completa tus hábitos diarios durante 14 días sin interrupciones.', 'Autodominio físico y mental', 'disciplina', 3, 2, 'hard', 40, 8, ARRAY['racha', 'consistencia']),
('disciplina_3', 'Elimina un hábito tóxico', 'Identifica y elimina completamente un hábito que te perjudica.', 'Autodominio físico y mental', 'disciplina', 3, 3, 'hard', 35, 7, ARRAY['eliminación', 'cambio']),
('disciplina_4', 'Aplica "Esfuerzo Inteligente"', 'Trabaja más eficientemente, no más duro, durante una semana.', 'Consistencia', 'disciplina', 3, 4, 'medium', 25, 5, ARRAY['eficiencia', 'inteligencia']),
('disciplina_5', 'Crea tu sistema de recompensas', 'Diseña un sistema de recompensas que te motive consistentemente.', 'Consistencia', 'disciplina', 3, 5, 'medium', 25, 5, ARRAY['recompensas', 'motivación']),
('disciplina_6', 'Entrena cuando menos quieras', 'Completa una sesión de ejercicio cuando tu motivación esté en el mínimo.', 'Consistencia', 'disciplina', 3, 6, 'hard', 30, 6, ARRAY['disciplina', 'entrenamiento']),
('disciplina_7', 'Registra tu progreso con honestidad', 'Mantén un registro diario honesto de tus avances y retrocesos.', 'Consistencia', 'disciplina', 3, 7, 'medium', 20, 4, ARRAY['honestidad', 'registro']),
('disciplina_8', 'Crea un ritual matinal de 3 pasos', 'Establece un ritual de 3 pasos que marques el inicio de tu día.', 'Consistencia', 'disciplina', 3, 8, 'medium', 20, 4, ARRAY['ritual', 'mañana']),
('disciplina_9', 'Semana sin azúcar ni farfolla digital', 'Elimina el azúcar refinado y limita el scrolling innecesario por 7 días.', 'Consistencia', 'disciplina', 3, 9, 'hard', 35, 7, ARRAY['eliminación', 'semana']),
('disciplina_10', 'Rompe la cadena de excusas', 'Durante 24 horas, enfréntate a cada excusa con acción inmediata.', 'Consistencia', 'disciplina', 3, 10, 'hard', 30, 6, ARRAY['excusas', 'acción']);

-- FASE 4 – SINERGIA (Arcos 4 y 8) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('sinergia_1', 'Detecta tus TDRs naturales', 'Identifica tus Talentos, Dones y Recursos únicos.', 'TDRs y equilibrio integral', 'sinergia', 4, 1, 'medium', 25, 5, ARRAY['autodescubrimiento', 'talentos']),
('sinergia_2', 'Mejora un área sin tocarla directamente', 'Trabaja en una área relacionada para mejorar otra indirectamente.', 'TDRs y equilibrio integral', 'sinergia', 4, 2, 'medium', 25, 5, ARRAY['sinergia', 'indirecto']),
('sinergia_3', 'Semana de equilibrio entre salud, amor y trabajo', 'Dedica tiempo equilibrado a tus tres JVCs durante 7 días.', 'TDRs y equilibrio integral', 'sinergia', 4, 3, 'hard', 35, 7, ARRAY['equilibrio', 'jvc']),
('sinergia_4', 'Crea tu "Estrategia de Equilibrio Vital"', 'Diseña una estrategia personal para mantener el equilibrio entre tus áreas vitales.', 'Inteligencia Integral', 'sinergia', 4, 4, 'hard', 35, 7, ARRAY['estrategia', 'equilibrio']),
('sinergia_5', 'Observa cómo tu salud afecta tu productividad', 'Registra durante una semana cómo tu estado físico impacta tu trabajo.', 'Inteligencia Integral', 'sinergia', 4, 5, 'medium', 25, 5, ARRAY['observación', 'conexión']),
('sinergia_6', 'Hackea tu entorno social', 'Optimiza tu círculo social para apoyar tus objetivos.', 'Inteligencia Integral', 'sinergia', 4, 6, 'medium', 25, 5, ARRAY['redes', 'optimización']),
('sinergia_7', 'Crea una rutina de triple mejora', 'Establece una rutina que mejore simultáneamente cuerpo, mente y relaciones.', 'Equilibrio holístico', 'sinergia', 4, 7, 'hard', 35, 7, ARRAY['rutina', 'triple']),
('sinergia_8', 'Practica "1 + 1 + 1 > 3"', 'Combina actividades de diferentes áreas para crear sinergia mayor.', 'Equilibrio holístico', 'sinergia', 4, 8, 'medium', 25, 5, ARRAY['sinergia', 'combinación']),
('sinergia_9', 'Mide tu energía integral diaria', 'Registra tu energía física, mental, emocional y social cada día.', 'Equilibrio holístico', 'sinergia', 4, 9, 'medium', 20, 4, ARRAY['medición', 'integral']),
('sinergia_10', 'Integra el aprendizaje con la acción', 'Aplica inmediatamente lo que aprendes en tus actividades diarias.', 'Equilibrio holístico', 'sinergia', 4, 10, 'medium', 25, 5, ARRAY['aprendizaje', 'acción']);

-- FASE 5 – DISOLUCIÓN (Arcos 5 y 9) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('disolucion_1', 'Observa tu ego hablando', 'Durante una conversación, observa cómo habla tu ego sin intervenir.', 'Reprogramación mental', 'disolucion', 5, 1, 'medium', 25, 5, ARRAY['ego', 'observación']),
('disolucion_2', 'Disuelve una emoción recurrente', 'Trabaja activamente para liberar una emoción que te limita recurrentemente.', 'Reprogramación mental', 'disolucion', 5, 2, 'hard', 35, 7, ARRAY['emociones', 'liberación']),
('disolucion_3', 'Reto: 3 días sin resolver nada', 'Durante 72 horas, no intentes resolver problemas, solo obsérvalos.', 'Reprogramación mental', 'disolucion', 5, 3, 'hard', 40, 8, ARRAY['reto', 'observación']),
('disolucion_4', 'Redefine el éxito en tus términos', 'Reescribe tu definición personal de éxito alejada de estándares externos.', 'Desapego emocional', 'disolucion', 5, 4, 'medium', 25, 5, ARRAY['éxito', 'redefinición']),
('disolucion_5', 'Practica "no acción eficaz"', 'Dedica tiempo a no hacer nada conscientemente, sin distracciones.', 'Desapego emocional', 'disolucion', 5, 5, 'medium', 25, 5, ARRAY['no-acción', 'presencia']),
('disolucion_6', 'Crea tu mantra NK personal', 'Desarrolla un mantra que encapsule tu camino Kaizeneka personal.', 'Desapego emocional', 'disolucion', 5, 6, 'medium', 20, 4, ARRAY['mantra', 'personal']),
('disolucion_7', 'Una semana sin dopamina basura', 'Elimina todas las fuentes de gratificación instantánea artificial por 7 días.', 'Paz interior', 'disolucion', 5, 7, 'hard', 40, 8, ARRAY['dopamina', 'desintoxicación']),
('disolucion_8', 'Mide tu paz interior diaria', 'Registra tu nivel de paz interior en una escala del 1 al 10 cada día.', 'Paz interior', 'disolucion', 5, 8, 'easy', 15, 3, ARRAY['paz', 'medición']),
('disolucion_9', 'Aprende a no reaccionar', 'Durante situaciones desafiantes, practica la no-reacción consciente.', 'Paz interior', 'disolucion', 5, 9, 'hard', 30, 6, ARRAY['no-reacción', 'paciencia']),
('disolucion_10', 'Gratitud radical diaria', 'Practica la gratitud por absolutamente todo, incluyendo lo negativo.', 'Paz interior', 'disolucion', 5, 10, 'medium', 20, 4, ARRAY['gratitud', 'radical']);

-- FASE 6 – SOBRADEZ (Arcos 6 y 10) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('sobradez_1', 'Vive un día desde tu versión sobrada', 'Actúa durante 24 horas como si ya fueras la versión más confiada de ti mismo.', 'Liderazgo y coherencia', 'sobradez', 6, 1, 'hard', 35, 7, ARRAY['confianza', 'versión-sobrada']),
('sobradez_2', 'Elimina toda excusa 24h', 'Durante un día completo, enfréntate a cada excusa con acción inmediata.', 'Liderazgo y coherencia', 'sobradez', 6, 2, 'hard', 35, 7, ARRAY['excusas', 'acción']),
('sobradez_3', 'Reto: No reaccionar bajo presión', 'Mantén la calma y la coherencia durante situaciones de alta presión.', 'Liderazgo y coherencia', 'sobradez', 6, 3, 'hard', 40, 8, ARRAY['presión', 'calma']),
('sobradez_4', 'Alinea tus tres JVCs conscientemente', 'Toma decisiones que beneficien simultáneamente tus tres áreas vitales.', 'Acción equilibrada', 'sobradez', 6, 4, 'medium', 25, 5, ARRAY['alineación', 'jvc']),
('sobradez_5', 'Diseña tu "Misión Sobrada"', 'Crea una declaración de propósito que te impulse hacia adelante.', 'Acción equilibrada', 'sobradez', 6, 5, 'medium', 25, 5, ARRAY['misión', 'propósito']),
('sobradez_6', 'Lidera con presencia', 'Dirige situaciones con confianza y claridad, sin necesidad de controlar.', 'Acción equilibrada', 'sobradez', 6, 6, 'medium', 25, 5, ARRAY['liderazgo', 'presencia']),
('sobradez_7', 'Aplica foco estratégico una semana', 'Trabaja solo en lo que realmente importa durante 7 días.', 'Acción equilibrada', 'sobradez', 6, 7, 'hard', 35, 7, ARRAY['foco', 'estratégico']),
('sobradez_8', 'Enseña sin predicar', 'Comparte conocimientos con otros sin intentar convencerlos.', 'Servicio y legado', 'sobradez', 6, 8, 'medium', 20, 4, ARRAY['enseñanza', 'compartir']),
('sobradez_9', 'Crea un mini dojo con otro usuario', 'Ayuda a otro usuario en su camino Kaizeneka durante una semana.', 'Servicio y legado', 'sobradez', 6, 9, 'medium', 25, 5, ARRAY['mentoría', 'comunidad']),
('sobradez_10', 'Integra el fracaso como maestro', 'Aprende activamente de cada error o fracaso que experimentes.', 'Servicio y legado', 'sobradez', 6, 10, 'medium', 20, 4, ARRAY['aprendizaje', 'fracaso']);

-- FASE 7 – TRASCENDENCIA (Arcos 11 y 12) - 10 misiones
INSERT INTO public.narrative_missions (id, title, description, principle, arc, phase, order_in_phase, difficulty, xp_reward, coins_reward, tags) VALUES
('trascendencia_1', 'Crea una Misión de Impacto Global', 'Define cómo contribuirás al mundo más allá de tu beneficio personal.', 'Servicio y legado', 'trascendencia', 7, 1, 'hard', 40, 8, ARRAY['impacto', 'global']),
('trascendencia_2', 'Dona XP a otro usuario', 'Comparte tus puntos de experiencia con alguien que lo necesite.', 'Servicio y legado', 'trascendencia', 7, 2, 'easy', 15, 3, ARRAY['donación', 'comunidad']),
('trascendencia_3', 'Enseña un principio NK públicamente', 'Comparte un principio Kaizeneka con tu comunidad o red social.', 'Servicio y legado', 'trascendencia', 7, 3, 'medium', 25, 5, ARRAY['enseñanza', 'público']),
('trascendencia_4', 'Escribe tu "Carta del Sensei"', 'Redacta una carta a tu yo futuro compartiendo tu sabiduría adquirida.', 'Disolución del ego', 'trascendencia', 7, 4, 'medium', 25, 5, ARRAY['carta', 'futuro']),
('trascendencia_5', 'Vive un día sin validación externa', 'Realiza actividades por puro disfrute interno, sin compartirlas.', 'Disolución del ego', 'trascendencia', 7, 5, 'hard', 35, 7, ARRAY['validación', 'interno']),
('trascendencia_6', 'Practica el Silencio 24h', 'Mantén silencio absoluto durante 24 horas, comunicándote solo lo esencial.', 'Disolución del ego', 'trascendencia', 7, 6, 'hard', 40, 8, ARRAY['silencio', 'presencia']),
('trascendencia_7', 'Lidera una tribu Kaizeneka', 'Forma o únete a un grupo de practicantes para guiar colectivamente.', 'Cierre del ciclo vital NK', 'trascendencia', 7, 7, 'hard', 40, 8, ARRAY['liderazgo', 'comunidad']),
('trascendencia_8', 'Disuelve la dualidad éxito-fracaso', 'Practica ver todas las experiencias como igualmente valiosas.', 'Cierre del ciclo vital NK', 'trascendencia', 7, 8, 'hard', 35, 7, ARRAY['dualidad', 'aceptación']),
('trascendencia_9', 'Meditación lúcida diaria', 'Practica meditación consciente durante 20 minutos cada día por una semana.', 'Cierre del ciclo vital NK', 'trascendencia', 7, 9, 'medium', 30, 6, ARRAY['meditación', 'diaria']),
('trascendencia_10', 'Transmite el legado Kaizeneka', 'Encuentra formas creativas de compartir los principios con las nuevas generaciones.', 'Cierre del ciclo vital NK', 'trascendencia', 7, 10, 'medium', 25, 5, ARRAY['legado', 'transmisión']);

-- Insertar logros del sistema
INSERT INTO public.achievements (id, name, description, icon, conditions, rewards) VALUES
('comienzo_epico', 'Comienzo Épico', 'Completa tu primera tarea', '🌟', '{"type": "first_task_completed"}', '{"xp": 5}'),
('maniatico_orden', 'Maníatico del Orden', '10 tareas en 1 día', '📋', '{"type": "tasks_in_day", "count": 10}', '{"xp": 10}'),
('maestro_habito', 'Maestro del Hábito', 'Mantén un hábito 14 días', '🎯', '{"type": "habit_streak", "days": 14}', '{"xp": 25}'),
('productor_legendario', 'Productor Legendario', 'Llega al nivel 10', '👑', '{"type": "level_reached", "level": 10}', '{"xp": 50, "coins": 20}'),
('despertar_completo', 'Despertar Completo', 'Completa todas las misiones del Arco 1', '🌅', '{"type": "arc_completed", "arc": "despertar"}', '{"xp": 100, "coins": 25}'),
('sobrado_nk', 'Sobrado NK', 'Completa el Arco 6', '💎', '{"type": "arc_completed", "arc": "sobradez"}', '{"xp": 200, "coins": 50}');

-- =========================================
-- SAMPLE DATA (Optional - for testing)
-- =========================================

-- Insert some predefined tasks
INSERT INTO public.predefined_tasks (title, notes, difficulty, category) VALUES
('Hacer ejercicio 30 minutos', 'Ejercicio cardiovascular o de fuerza', 'medium', 'Salud'),
('Leer 20 páginas de un libro', 'Lectura para expandir conocimientos', 'easy', 'Educación'),
('Meditar 10 minutos', 'Meditación mindfulness', 'easy', 'Bienestar'),
('Organizar el escritorio', 'Limpiar y ordenar el espacio de trabajo', 'easy', 'Productividad'),
('Llamar a un familiar', 'Mantener contacto con la familia', 'easy', 'Relaciones'),
('Aprender 5 palabras nuevas', 'En un idioma extranjero', 'medium', 'Educación'),
('Hacer una caminata', 'Caminata al aire libre', 'easy', 'Salud'),
('Escribir en el diario', 'Reflexionar sobre el día', 'easy', 'Bienestar');

-- Insert some predefined missions
INSERT INTO public.predefined_missions (title, notes, difficulty, points, category) VALUES
('Completar rutina de ejercicio semanal', '7 días de ejercicio', 'hard', 100, 'Salud'),
('Leer un libro completo', 'Libro de al menos 200 páginas', 'medium', 75, 'Educación'),
('Aprender una nueva habilidad', 'Curso online o práctica', 'hard', 150, 'Desarrollo'),
('Organizar la casa', 'Limpieza general y organización', 'medium', 50, 'Productividad'),
('Conectar con 5 amigos', 'Llamadas o mensajes significativos', 'easy', 25, 'Relaciones'),
('Crear un presupuesto mensual', 'Planificación financiera', 'medium', 60, 'Finanzas'),
('Hacer voluntariado', 'Ayudar en una causa social', 'medium', 80, 'Comunidad');

-- Insert some predefined habits
INSERT INTO public.predefined_habits (title, notes, difficulty, repeat_type, category) VALUES
('Beber 8 vasos de agua', 'Hidratación diaria', 'easy', 'daily', 'Salud'),
('Hacer estiramientos matutinos', '5-10 minutos de estiramientos', 'easy', 'daily', 'Salud'),
('Escribir 3 cosas positivas', 'Diario de gratitud', 'easy', 'daily', 'Bienestar'),
('Leer 30 minutos', 'Lectura antes de dormir', 'medium', 'daily', 'Educación'),
('Hacer ejercicio', 'Actividad física regular', 'medium', 'daily', 'Salud'),
('Meditar', 'Meditación diaria', 'easy', 'daily', 'Bienestar'),
('Planificar el día', 'Revisar tareas y prioridades', 'easy', 'daily', 'Productividad'),
('Aprender algo nuevo', '15 minutos de aprendizaje', 'medium', 'daily', 'Educación');

-- =========================================
-- SETUP COMPLETE
-- =========================================

-- Note: After running this script, you may need to:
-- 1. Set up authentication in Supabase Dashboard
-- 2. Configure RLS policies as needed
-- 3. Create any additional indexes based on query patterns
-- 4. Set up real-time subscriptions if needed

-- The database is now ready for the NK+ task management system!