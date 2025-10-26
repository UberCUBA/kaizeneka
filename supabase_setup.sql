-- =========================================
-- SUPABASE SETUP FOR NK+ TASK MANAGEMENT
-- =========================================

-- Enable Row Level Security (RLS) on all tables
-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================
-- USERS TABLE (extends auth.users)
-- =========================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    belt TEXT DEFAULT 'Blanco',
    points INTEGER DEFAULT 0,
    dias_completados INTEGER DEFAULT 0,
    misiones_completadas TEXT[] DEFAULT '{}',
    logros_desbloqueados TEXT[] DEFAULT '{}',
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
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