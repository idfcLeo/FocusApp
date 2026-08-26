-- Focus App - Supabase Database Schema Setup
-- Run this script in your Supabase Dashboard -> SQL Editor

-- 1. USER PROFILES & GOAL PLANS TABLE
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id TEXT PRIMARY KEY DEFAULT 'default_user',
    weight DOUBLE PRECISION DEFAULT 70.0,
    height DOUBLE PRECISION DEFAULT 170.0,
    age INT DEFAULT 21,
    sex TEXT DEFAULT 'Male',
    activity_level TEXT DEFAULT 'Moderate',
    active_plan TEXT DEFAULT 'Weight Loss Plan',
    calorie_goal INT DEFAULT 2400,
    protein_goal INT DEFAULT 120,
    water_goal INT DEFAULT 3000,
    step_goal INT DEFAULT 10000,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TASKS TABLE
CREATE TABLE IF NOT EXISTS public.tasks (
    id TEXT PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    title TEXT NOT NULL,
    category TEXT DEFAULT 'Study',
    priority TEXT DEFAULT 'Medium',
    due_time TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. HABITS TABLE
CREATE TABLE IF NOT EXISTS public.habits (
    id TEXT PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    title TEXT NOT NULL,
    icon TEXT DEFAULT '📚',
    category TEXT DEFAULT 'Study',
    streak_count INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    completed_dates TEXT[] DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. FOOD LOGS TABLE
CREATE TABLE IF NOT EXISTS public.food_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    name TEXT NOT NULL,
    calories INT DEFAULT 0,
    protein_grams DOUBLE PRECISION DEFAULT 0.0,
    carbs_grams DOUBLE PRECISION DEFAULT 0.0,
    fat_grams DOUBLE PRECISION DEFAULT 0.0,
    portion_grams INT DEFAULT 100,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. EXERCISE LOGS TABLE
CREATE TABLE IF NOT EXISTS public.exercise_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    title TEXT NOT NULL,
    duration_minutes INT DEFAULT 30,
    calories_burned INT DEFAULT 150,
    steps INT DEFAULT 0,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. WATER HYDRATION LOGS TABLE
CREATE TABLE IF NOT EXISTS public.water_logs (
    id SERIAL PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    log_date DATE NOT NULL,
    intake_ml INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, log_date)
);

-- 7. SLEEP LOGS TABLE
CREATE TABLE IF NOT EXISTS public.sleep_logs (
    id SERIAL PRIMARY KEY,
    user_id TEXT DEFAULT 'default_user',
    log_date DATE NOT NULL,
    sleep_hours DOUBLE PRECISION DEFAULT 7.5,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, log_date)
);

-- Enable Row Level Security (RLS) policies (Optional / Open for development)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public full access" ON public.user_profiles FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.tasks FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.habits FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.food_logs FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.exercise_logs FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.water_logs FOR ALL USING (true);
CREATE POLICY "Allow public full access" ON public.sleep_logs FOR ALL USING (true);
