CREATE DATABASE IF NOT EXISTS diagnostichub;
USE diagnostichub;

-- Users
CREATE TABLE IF NOT EXISTS manufacturers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255)
);

INSERT INTO manufacturers (name, password, email)
VALUES ('Acurable', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'someone@acurable.com');

-- Wearables
CREATE TABLE IF NOT EXISTS wearables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer INT NOT NULL,
    name UNIQUE VARCHAR(255),
    description TEXT DEFAULT NULL,
    image_url VARCHAR(512) DEFAULT NULL,
    video_url VARCHAR(512) DEFAULT NULL,
    forwarding_address VARCHAR(255) DEFAULT 'http://localhost',
    forwarding_port INT DEFAULT 8080,
    is_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_type ENUM('automatic', 'manual') DEFAULT 'automatic',
    version VARCHAR(255),
    FOREIGN KEY (manufacturer) REFERENCES manufacturers(id)
);

INSERT INTO wearables (manufacturer, name, description, forwarding_address, forwarding_port, is_enabled, record_type, version)
VALUES (1, 'AcuPebble', 'Sleep Aponea Diagnostic Tool', 'http://google.com', 8080, true, 'manual', '1.0');

-- Questions
CREATE TABLE IF NOT EXISTS questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    wearable INT NOT NULL,
    question TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wearable) REFERENCES wearables(id)
);

INSERT INTO questions (wearable, question)
VALUES (1, 'How much did you sleep last night?');

-- Studies
CREATE TABLE IF NOT EXISTS studies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    wearable INT NOT NULL,
    start_date DATE,
    end_date DATE,
    status ENUM('planned', 'active', 'completed') DEFAULT 'planned',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_of_birth DATE NOT NULL,
    activation_code VARCHAR(255),
    FOREIGN KEY (wearable) REFERENCES wearables(id)
);