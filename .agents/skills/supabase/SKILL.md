---
name: supabase
description: Expert guidance, schema management, authentication workflows, and best practices for Supabase backends.
---

# Supabase Agent Skill

This skill provides ready-made instructions and best practices for integrating, managing, and debugging Supabase backends.

## Key Capabilities

1. **Authentication & Session Management**:
   - Use `supabase_flutter` for client-side Auth (`signUp`, `signInWithPassword`, `signOut`, `onAuthStateChange`).
   - Store user sessions persistently and link app user profiles to `auth.users(id)`.

2. **Row Level Security (RLS)**:
   - Enable RLS on all user-owned tables (`ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;`).
   - Restrict read/write operations to `auth.uid() = user_id`.
   - Shared reference data (e.g. companies, public question banks) should be granted read access to all authenticated users (`USING (true)`).

3. **Database Schema & SQL Migrations**:
   - Keep SQL definitions in `supabase_schema.sql`.
   - Define triggers to auto-populate `public.profiles` when new rows are added to `auth.users`.
