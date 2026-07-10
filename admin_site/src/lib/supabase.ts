import { createClient } from '@supabase/supabase-js';

// Reusing existing project credentials from the root .env
// Ensure these variables are available in the web app environment
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
