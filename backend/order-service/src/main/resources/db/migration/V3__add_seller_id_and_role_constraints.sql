-- Add seller_id column to order_items table with a temporary default, then drop the default
ALTER TABLE order_items ADD COLUMN seller_id TEXT NOT NULL DEFAULT 'seller-demo';
ALTER TABLE order_items ALTER COLUMN seller_id DROP DEFAULT;

-- Create PostgreSQL ENUM type for roles
CREATE TYPE user_role AS ENUM ('BUYER', 'SELLER', 'ADMIN');

-- Alter users.role column to use the new user_role ENUM type
ALTER TABLE users ALTER COLUMN role TYPE user_role USING role::user_role;
