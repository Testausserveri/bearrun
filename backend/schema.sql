CREATE TABLE users (
    uid VARCHAR(255) NOT NULL,
    bear_name VARCHAR(255) NOT NULL,
    invite_code VARCHAR(255),
    hue_deg INT,
    PRIMARY KEY (uid)
);

CREATE TABLE steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    steps INT NOT NULL,
    FOREIGN KEY (uid) REFERENCES users(uid)
);


ALTER TABLE users ADD COLUMN my_invite_code VARCHAR(10);
ALTER TABLE users ADD COLUMN phone_number VARCHAR(15);
ALTER TABLE steps ADD UNIQUE INDEX uid_date_unique (uid, date);
ALTER TABLE users ADD COLUMN is_dead BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN lat_long VARCHAR(255);
