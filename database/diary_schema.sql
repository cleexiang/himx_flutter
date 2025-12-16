-- =====================================================
-- Love Diary Module - Database Schema for Supabase
-- =====================================================

-- Create ENUM types
CREATE TYPE himx_diary_type AS ENUM (
    'firstMeet',
    'chatMoment',
    'sceneDate',
    'songMemory',
    'giftReceived',
    'milestone',
    'userNote',
    'anniversary'
);

-- 1. Diary Entries Table
-- Stores all diary entries for users
CREATE TABLE himx_diary (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profile(user_id) ON DELETE CASCADE,
    role_id TEXT NOT NULL,
    type himx_diary_type NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    media_urls TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Diary entries indexes
CREATE INDEX idx_himx_diary_user_role
    ON himx_diary(user_id, role_id);