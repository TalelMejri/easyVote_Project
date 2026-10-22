-- ============================================================
-- EasyVote — Jeu de données de test (comptes du README)
-- Mot de passe de tous les comptes : password123 (haché BCrypt cost 10)
-- Exécution : C:\xampp\mysql\bin\mysql.exe -uroot easyvote_db < tests\seed-demo.sql
-- (ou phpMyAdmin → easyvote_db → onglet SQL → coller ce fichier)
-- ============================================================

SET @pwd = '$2a$10$7lywx8rux6dSc2JntHxX4.CinQEW.pQh1iLNIh1tscN1WcwRA/akO';

INSERT INTO users (email, password, full_name, role, is_verified, created_at, updated_at) VALUES
  ('ahmed@test.com',  @pwd, 'Ahmed Ltayef',  'ADMIN',   1, NOW(), NOW()),
  ('achref@test.com', @pwd, 'Achref Ben Ali', 'STUDENT', 1, NOW(), NOW()),
  ('dali@test.com',   @pwd, 'Dali Trabelsi',  'STUDENT', 1, NOW(), NOW()),
  ('moez@test.com',   @pwd, 'Moez Gharbi',    'STUDENT', 1, NOW(), NOW()),
  ('talel@test.com',  @pwd, 'Talel Mejri',    'STUDENT', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE password = @pwd, is_verified = 1;
