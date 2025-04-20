
-- Create an enum for team member roles
CREATE TYPE team_role AS ENUM ('admin', 'member', 'viewer');

-- Create a table for team members
CREATE TABLE public.team_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    role team_role NOT NULL DEFAULT 'member',
    active BOOLEAN NOT NULL DEFAULT true,
    department TEXT,
    job_title TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing team members (all authenticated users can view)
CREATE POLICY "Allow authenticated users to view team members"
ON public.team_members
FOR SELECT
TO authenticated
USING (true);

-- Create policy for managing team members (only admins can insert/update/delete)
CREATE POLICY "Only admins can manage team members"
ON public.team_members
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.team_members
        WHERE user_id = auth.uid()
        AND role = 'admin'
    )
);

-- Update profiles table to include more user information
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS department TEXT,
ADD COLUMN IF NOT EXISTS job_title TEXT;

