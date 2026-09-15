-- ============================================================================
-- Maritime Merchant Navy Interview Pro - Supabase Database Schema & RLS Policies
-- Execute this SQL in your Supabase SQL Editor (https://app.supabase.com)
-- ============================================================================

-- 1. Student Profiles Table (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Trigger to automatically create a profile when a new auth user registers
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- 2. Shared Data: Companies (Readable by all authenticated users)
CREATE TABLE IF NOT EXISTS public.companies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  full_name TEXT NOT NULL,
  description TEXT NOT NULL,
  question_count INT DEFAULT 0,
  difficulty TEXT,
  category TEXT,
  is_recommended BOOLEAN DEFAULT FALSE,
  logo_text TEXT
);

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access on companies to authenticated users"
  ON public.companies FOR SELECT
  TO authenticated
  USING (true);


-- 3. Shared Data: Interview Questions (Readable by all authenticated users)
CREATE TABLE IF NOT EXISTS public.interview_questions (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  interview_tip TEXT,
  table_data JSONB
);

ALTER TABLE public.interview_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access on interview questions to authenticated users"
  ON public.interview_questions FOR SELECT
  TO authenticated
  USING (true);


-- 4. User Question Progress & Bookmarks (Private per user ID)
CREATE TABLE IF NOT EXISTS public.user_question_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_user_question UNIQUE(user_id, question_id)
);

ALTER TABLE public.user_question_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own question progress"
  ON public.user_question_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own question progress"
  ON public.user_question_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own question progress"
  ON public.user_question_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own question progress"
  ON public.user_question_progress FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- 5. Mock Interview Results (Private per user ID)
CREATE TABLE IF NOT EXISTS public.mock_interview_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  score INT NOT NULL,
  total_questions INT NOT NULL DEFAULT 10,
  correct_count INT NOT NULL DEFAULT 0,
  weak_category_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.mock_interview_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own mock results"
  ON public.mock_interview_results FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own mock results"
  ON public.mock_interview_results FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own mock results"
  ON public.mock_interview_results FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own mock results"
  ON public.mock_interview_results FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
