
-- CSI3450 Final (rleaks): People & Favorite Fruits (300,000 rows)
-- This script is self-contained. It creates the DB, schema, and loads 300k rows.
-- Restore with:
--   mysql -u root -h localhost -p csi3450_rleaks_final < rleaks_fruit_db.sql
-- Or non-interactively (XAMPP):
--   MYSQL_PWD=yourpassword mysql -u root -h localhost csi3450_rleaks_final < rleaks_fruit_db.sql

-- 1) Create & select your exam DB
CREATE DATABASE IF NOT EXISTS csi3450_rleaks_final;
USE csi3450_rleaks_final;

-- 2) Schema
DROP TABLE IF EXISTS people_favorite_fruits;
CREATE TABLE people_favorite_fruits (
  id INT NOT NULL AUTO_INCREMENT,
  person_name VARCHAR(100) NOT NULL,
  fruit VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fruit (fruit)
) ENGINE=InnoDB;

-- 3) Fruit dimension (10 fruits)
DROP TEMPORARY TABLE IF EXISTS _fruits;
CREATE TEMPORARY TABLE _fruits (
  id TINYINT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);
INSERT INTO _fruits (id, name) VALUES
(1,'Apple'),
(2,'Banana'),
(3,'Orange'),
(4,'Grape'),
(5,'Mango'),
(6,'Strawberry'),
(7,'Pineapple'),
(8,'Watermelon'),
(9,'Peach'),
(10,'Blueberry');

-- 4) Numbers generator (0..999999) using cross-joined digits
--    We'll select only 1..300000 for loading.
--    This avoids relying on recursive CTE limits.
INSERT INTO people_favorite_fruits (person_name, fruit)
SELECT
  CONCAT('Person_', LPAD(seq.n, 6, '0')) AS person_name,
  f.name AS fruit
FROM (
  SELECT (u.n + t.n*10 + h.n*100 + th.n*1000 + tth.n*10000 + hth.n*100000) AS n
  FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) u
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) h
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) th
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) tth
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) hth
) AS seq
JOIN _fruits f
  ON ((seq.n % 10) + 1) = f.id
WHERE seq.n BETWEEN 1 AND 300000
ORDER BY seq.n;

-- 5) Optional: show counts by fruit (for manual verification in class)
--    (Run these manually after import; leaving as comments so file is idempotent.)
-- SELECT COUNT(*) AS total_rows FROM people_favorite_fruits;
-- SELECT fruit, COUNT(*) AS cnt FROM people_favorite_fruits GROUP BY fruit ORDER BY cnt DESC;
-- SELECT * FROM people_favorite_fruits ORDER BY id LIMIT 10;
