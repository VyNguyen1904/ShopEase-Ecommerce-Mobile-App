ALTER TABLE user_addresses
ADD COLUMN latitude NUMERIC(10, 8),
ADD COLUMN longitude NUMERIC(11, 8);

ALTER TABLE orders
ADD COLUMN ship_latitude NUMERIC(10, 8),
ADD COLUMN ship_longitude NUMERIC(11, 8);
