CREATE TABLE themes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE problems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    theme_id UUID REFERENCES themes(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level IN (1, 2, 3)),
    type TEXT NOT NULL CHECK (type IN ('normal', 'fill_blank')),
    statement TEXT NOT NULL,
    requirements TEXT,
    hint TEXT,
    answer TEXT NOT NULL,
    explanation TEXT,
    common_mistakes TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE study_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    problem_id UUID REFERENCES problems(id) ON DELETE CASCADE,
    user_code TEXT,
    self_assessment TEXT CHECK (self_assessment IN ('success', 'close', 'fail')),
    is_strong BOOLEAN NOT NULL DEFAULT false,
    is_weak BOOLEAN NOT NULL DEFAULT false,
    last_studied_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, problem_id)
);

ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on themes" ON themes FOR SELECT USING (true);
CREATE POLICY "Allow public read access on problems" ON problems FOR SELECT USING (true);
CREATE POLICY "Users can create their own study records" ON study_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own study records" ON study_records FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can view their own study records" ON study_records FOR SELECT USING (auth.uid() = user_id);
