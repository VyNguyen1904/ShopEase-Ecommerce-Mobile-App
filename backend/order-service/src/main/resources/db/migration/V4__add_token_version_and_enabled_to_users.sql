-- Add token_version column to users table if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='token_version') THEN
        ALTER TABLE users ADD COLUMN token_version INT NOT NULL DEFAULT 0;
    END IF;
END $$;

-- Add enabled column to users table if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='enabled') THEN
        ALTER TABLE users ADD COLUMN enabled BOOLEAN NOT NULL DEFAULT TRUE;
    END IF;
END $$;
