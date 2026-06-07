-- Add seller_id column to order_items table with a temporary default, then drop the default if not already added
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='order_items' AND column_name='seller_id') THEN
        ALTER TABLE order_items ADD COLUMN seller_id TEXT NOT NULL DEFAULT 'seller-demo';
        ALTER TABLE order_items ALTER COLUMN seller_id DROP DEFAULT;
    END IF;
END $$;

-- Create PostgreSQL ENUM type for roles if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('BUYER', 'SELLER', 'ADMIN');
    END IF;
END $$;

-- Alter users.role column to use the new user_role ENUM type if not already user_role
DO $$
BEGIN
    BEGIN
        ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::user_role;
    EXCEPTION
        WHEN OTHERS THEN
            -- Ignore if already altered or other errors
            NULL;
    END;
END $$;
