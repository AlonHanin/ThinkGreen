-- Think Green - MySQL / MariaDB schema for cPanel hosting
-- Target stack: Flutter -> PHP API -> MySQL/MariaDB
-- Import this file through phpMyAdmin
-- Character set: utf8mb4

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS auth_tokens;
DROP TABLE IF EXISTS password_reset_pins;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS oauth_requests;
DROP TABLE IF EXISTS app_connections;
DROP TABLE IF EXISTS reward_redemptions;
DROP TABLE IF EXISTS rewards;
DROP TABLE IF EXISTS partner_businesses;
DROP TABLE IF EXISTS user_challenges;
DROP TABLE IF EXISTS challenges;
DROP TABLE IF EXISTS points_ledger;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS activity_definitions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(32) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL,
  phone VARCHAR(40) DEFAULT NULL,
  date_of_birth DATE DEFAULT NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url VARCHAR(255) DEFAULT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  locale VARCHAR(5) NOT NULL DEFAULT 'en',
  notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
  dark_mode TINYINT(1) NOT NULL DEFAULT 0,
  location_services_enabled TINYINT(1) NOT NULL DEFAULT 1,
  points_balance INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_public_id (public_id),
  UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE activity_definitions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(100) NOT NULL,
  title_en VARCHAR(150) NOT NULL,
  title_he VARCHAR(150) NOT NULL,
  description_en TEXT DEFAULT NULL,
  description_he TEXT DEFAULT NULL,
  default_points INT NOT NULL DEFAULT 0,
  default_source ENUM('manual','strava','moovit') NOT NULL DEFAULT 'manual',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_activity_definitions_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE activities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(36) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  activity_definition_id BIGINT UNSIGNED DEFAULT NULL,
  title_snapshot VARCHAR(150) NOT NULL,
  source ENUM('manual','strava','moovit') NOT NULL DEFAULT 'manual',
  activity_datetime DATETIME NOT NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  points_awarded INT NOT NULL DEFAULT 0,
  image_path VARCHAR(255) DEFAULT NULL,
  image_mime VARCHAR(100) DEFAULT NULL,
  image_original_name VARCHAR(255) DEFAULT NULL,
  ai_tags_json TEXT DEFAULT NULL,
  client_verified TINYINT(1) NOT NULL DEFAULT 0,
  review_notes TEXT DEFAULT NULL,
  reviewed_by BIGINT UNSIGNED DEFAULT NULL,
  reviewed_at DATETIME DEFAULT NULL,
  external_provider VARCHAR(50) DEFAULT NULL,
  external_activity_id VARCHAR(120) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_activities_public_id (public_id),
  UNIQUE KEY uk_activities_external_provider_id (external_provider, external_activity_id),
  KEY idx_activities_user (user_id),
  KEY idx_activities_status (status),
  KEY idx_activities_definition (activity_definition_id),
  KEY idx_activities_reviewed_by (reviewed_by),
  CONSTRAINT fk_activities_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_activities_definition FOREIGN KEY (activity_definition_id) REFERENCES activity_definitions(id) ON DELETE SET NULL,
  CONSTRAINT fk_activities_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE points_ledger (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  points_delta INT NOT NULL,
  reason_code VARCHAR(50) NOT NULL,
  reference_type VARCHAR(50) DEFAULT NULL,
  reference_id BIGINT UNSIGNED DEFAULT NULL,
  note VARCHAR(255) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_points_ledger_user (user_id),
  KEY idx_points_ledger_ref (reference_type, reference_id),
  UNIQUE KEY uk_points_ledger_unique_event (user_id, reason_code, reference_type, reference_id),
  CONSTRAINT fk_points_ledger_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE challenges (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(100) NOT NULL,
  title_en VARCHAR(150) NOT NULL,
  title_he VARCHAR(150) NOT NULL,
  description_en TEXT DEFAULT NULL,
  description_he TEXT DEFAULT NULL,
  icon VARCHAR(10) DEFAULT '🏆',
  points_bonus INT NOT NULL DEFAULT 0,
  target_count INT NOT NULL DEFAULT 1,
  linked_activity_definition_id BIGINT UNSIGNED NOT NULL,
  end_date DATETIME DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_challenges_slug (slug),
  KEY idx_challenges_linked_activity (linked_activity_definition_id),
  CONSTRAINT fk_challenges_linked_activity FOREIGN KEY (linked_activity_definition_id) REFERENCES activity_definitions(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_challenges (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  challenge_id BIGINT UNSIGNED NOT NULL,
  current_count INT NOT NULL DEFAULT 0,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  completed_at DATETIME DEFAULT NULL,
  reward_granted TINYINT(1) NOT NULL DEFAULT 0,
  reward_granted_at DATETIME DEFAULT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_challenges_user_challenge (user_id, challenge_id),
  KEY idx_user_challenges_completed (is_completed),
  CONSTRAINT fk_user_challenges_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_challenges_challenge FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE partner_businesses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  rewards_text VARCHAR(255) DEFAULT NULL,
  location_text VARCHAR(255) DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rewards (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(40) NOT NULL,
  partner_business_id BIGINT UNSIGNED DEFAULT NULL,
  title_en VARCHAR(150) NOT NULL,
  title_he VARCHAR(150) NOT NULL,
  description_en TEXT DEFAULT NULL,
  description_he TEXT DEFAULT NULL,
  points_cost INT NOT NULL DEFAULT 0,
  emoji VARCHAR(10) DEFAULT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_rewards_public_id (public_id),
  KEY idx_rewards_partner_business (partner_business_id),
  CONSTRAINT fk_rewards_partner_business FOREIGN KEY (partner_business_id) REFERENCES partner_businesses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reward_redemptions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  public_id VARCHAR(40) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  reward_id BIGINT UNSIGNED NOT NULL,
  redemption_code VARCHAR(40) NOT NULL,
  status ENUM('active','used','expired','cancelled') NOT NULL DEFAULT 'active',
  redeemed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  used_at DATETIME DEFAULT NULL,
  expires_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_reward_redemptions_public_id (public_id),
  UNIQUE KEY uk_reward_redemptions_code (redemption_code),
  KEY idx_reward_redemptions_user (user_id),
  KEY idx_reward_redemptions_reward (reward_id),
  CONSTRAINT fk_reward_redemptions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reward_redemptions_reward FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE app_connections (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  provider VARCHAR(50) NOT NULL,
  external_user_id VARCHAR(120) DEFAULT NULL,
  connection_status ENUM('connected','disconnected','pending') NOT NULL DEFAULT 'pending',
  connected_at DATETIME DEFAULT NULL,
  last_synced_at DATETIME DEFAULT NULL,
  access_token VARCHAR(255) DEFAULT NULL,
  refresh_token VARCHAR(255) DEFAULT NULL,
  token_expires_at DATETIME DEFAULT NULL,
  scopes VARCHAR(255) DEFAULT NULL,
  provider_payload_json LONGTEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_app_connections_user_provider (user_id, provider),
  CONSTRAINT fk_app_connections_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE oauth_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED DEFAULT NULL,
  provider VARCHAR(50) NOT NULL,
  purpose VARCHAR(50) NOT NULL,
  state VARCHAR(120) NOT NULL,
  handoff_code VARCHAR(120) DEFAULT NULL,
  result_payload_json LONGTEXT DEFAULT NULL,
  completed_at DATETIME DEFAULT NULL,
  consumed_at DATETIME DEFAULT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_oauth_requests_state (state),
  UNIQUE KEY uk_oauth_requests_handoff_code (handoff_code),
  KEY idx_oauth_requests_user_provider (user_id, provider),
  CONSTRAINT fk_oauth_requests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(190) NOT NULL,
  body TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'general',
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  metadata_json TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_notifications_user_read (user_id, is_read),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE password_reset_pins (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  pin_code VARCHAR(10) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_password_reset_pins_user (user_id),
  CONSTRAINT fk_password_reset_pins_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  last_used_at DATETIME DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_auth_tokens_hash (token_hash),
  KEY idx_auth_tokens_user (user_id),
  CONSTRAINT fk_auth_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO activity_definitions (slug, title_en, title_he, description_en, description_he, default_points, default_source, is_active, sort_order) VALUES
('recycled_plastic_bottles', 'Recycled Plastic Bottles', 'מיחזרתי בקבוקי פלסטיק', 'Uploaded a report for recycling plastic bottles.', 'דיווח ידני על מיחזור בקבוקי פלסטיק.', 20, 'manual', 1, 1),
('used_public_transport', 'Used Public Transport', 'השתמשתי בתחבורה ציבורית', 'Uploaded a report for using public transport.', 'דיווח על נסיעה בתחבורה ציבורית.', 25, 'manual', 1, 2),
('used_reusable_bottle', 'Used A Reusable Bottle', 'השתמשתי בבקבוק רב פעמי', 'Uploaded a report for using a reusable bottle.', 'דיווח על שימוש בבקבוק רב פעמי.', 15, 'manual', 1, 3),
('walked_biked_to_work', 'Walked / Biked to Work', 'הלכתי / רכבתי לעבודה', 'Uploaded a report for walking or biking to work.', 'דיווח על הליכה או רכיבה לעבודה.', 30, 'manual', 1, 4);

INSERT INTO challenges (slug, title_en, title_he, description_en, description_he, icon, points_bonus, target_count, linked_activity_definition_id, end_date, is_active, sort_order)
SELECT 'no_plastic_week', 'No Plastic Week', 'שבוע בלי פלסטיק',
       'Use a reusable bottle or skip plastic bags for 7 actions.',
       'בצעו 7 פעולות של שימוש חוזר או הימנעות מפלסטיק.',
       '♻️', 500, 7, id, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY), 1, 1
FROM activity_definitions WHERE slug = 'used_reusable_bottle';

INSERT INTO challenges (slug, title_en, title_he, description_en, description_he, icon, points_bonus, target_count, linked_activity_definition_id, end_date, is_active, sort_order)
SELECT 'public_transport_streak', 'Public Transport Streak', 'רצף תחבורה ציבורית',
       'Choose buses or public transport 5 times this month.',
       'בחרו באוטובוס או תחבורה ציבורית 5 פעמים החודש.',
       '🚌', 350, 5, id, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY), 1, 2
FROM activity_definitions WHERE slug = 'used_public_transport';

INSERT INTO challenges (slug, title_en, title_he, description_en, description_he, icon, points_bonus, target_count, linked_activity_definition_id, end_date, is_active, sort_order)
SELECT 'recycling_sprint', 'Recycling Sprint', 'ספרינט מחזור',
       'Submit and complete 3 recycling actions.',
       'השלימו 3 פעולות מחזור מאושרות.',
       '🌱', 250, 3, id, DATE_ADD(UTC_TIMESTAMP(), INTERVAL 30 DAY), 1, 3
FROM activity_definitions WHERE slug = 'recycled_plastic_bottles';

INSERT INTO partner_businesses (name, rewards_text, location_text, is_active, sort_order) VALUES
('Eco Coffee Hub', 'Coffee rewards, reusable cup benefits', 'Main St. 12', 1, 1),
('Green Fashion', 'Discounts, tote bags, eco accessories', 'Shopping Mall, Floor 1', 1, 2),
('Nature Market', 'Fresh produce discounts', 'North Ave. 45', 1, 3),
('Bio Bakery', 'Free drink upgrades and pastry deals', 'Central Square', 1, 4);

INSERT INTO rewards (public_id, partner_business_id, title_en, title_he, description_en, description_he, points_cost, emoji, is_active, sort_order)
SELECT 'reward-1', id, 'Free Coffee (Reusable Cup)', 'קפה חינם עם כוס רב פעמית',
       'One free regular coffee when using a reusable cup.',
       'קפה רגיל אחד בחינם בשימוש בכוס רב פעמית.',
       250, '☕', 1, 1
FROM partner_businesses WHERE name = 'Eco Coffee Hub';

INSERT INTO rewards (public_id, partner_business_id, title_en, title_he, description_en, description_he, points_cost, emoji, is_active, sort_order)
SELECT 'reward-2', id, '10% Store Discount', '10% הנחה בחנות',
       'Single-use 10% discount on one purchase.',
       'שובר חד פעמי ל-10% הנחה על רכישה אחת.',
       300, '🛍️', 1, 2
FROM partner_businesses WHERE name = 'Green Fashion';

INSERT INTO rewards (public_id, partner_business_id, title_en, title_he, description_en, description_he, points_cost, emoji, is_active, sort_order)
SELECT 'reward-3', id, 'Bus Ticket Credit', 'זיכוי לכרטיס אוטובוס',
       'Transit credit voucher for one bus ride.',
       'שובר זיכוי לנסיעה אחת באוטובוס.',
       200, '🚌', 1, 3
FROM partner_businesses WHERE name = 'Nature Market';

INSERT INTO rewards (public_id, partner_business_id, title_en, title_he, description_en, description_he, points_cost, emoji, is_active, sort_order)
SELECT 'reward-4', id, 'Tree Planting Donation', 'תרומת נטיעת עץ',
       'Convert your points into a sponsored tree planting.',
       'המרת הנקודות לתרומת נטיעת עץ.',
       300, '🌳', 1, 4
FROM partner_businesses WHERE name = 'Nature Market';

INSERT INTO rewards (public_id, partner_business_id, title_en, title_he, description_en, description_he, points_cost, emoji, is_active, sort_order)
SELECT 'reward-5', id, 'Free Drink Upgrade', 'שדרוג משקה חינם',
       'Upgrade one drink size for free.',
       'שדרוג גודל משקה אחד ללא עלות.',
       200, '🥤', 1, 5
FROM partner_businesses WHERE name = 'Bio Bakery';

SET FOREIGN_KEY_CHECKS = 1;
