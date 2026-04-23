ALTER TABLE activities
  ADD COLUMN external_provider VARCHAR(50) DEFAULT NULL AFTER reviewed_at,
  ADD COLUMN external_activity_id VARCHAR(120) DEFAULT NULL AFTER external_provider,
  ADD UNIQUE KEY uk_activities_external_provider_id (external_provider, external_activity_id);

ALTER TABLE app_connections
  ADD COLUMN access_token VARCHAR(255) DEFAULT NULL AFTER last_synced_at,
  ADD COLUMN refresh_token VARCHAR(255) DEFAULT NULL AFTER access_token,
  ADD COLUMN token_expires_at DATETIME DEFAULT NULL AFTER refresh_token,
  ADD COLUMN scopes VARCHAR(255) DEFAULT NULL AFTER token_expires_at,
  ADD COLUMN provider_payload_json LONGTEXT DEFAULT NULL AFTER scopes;

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
