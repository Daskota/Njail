ALTER TABLE users ADD COLUMN jail_ref INT DEFAULT 0;
ALTER TABLE users ADD COLUMN jail_reason VARCHAR(255) DEFAULT '';