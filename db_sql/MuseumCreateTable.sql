--TABLE CREATION QUERY--
--@ VEUILLET GAËTAN
-- 10.12.2025
-- Description : Create all the table as the scheme (except for type IMG column, it doesn't exist so we use PATH). Made with the docker's container we saw in course + beekeper

CREATE TABLE Exhibits (
  exhibit_id INT,
  title VARCHAR[50],
  short_desc VARCHAR[100],
  long_desc VARCHAR[300],
  start_date DATE,
  final_date DATE,
  branding VARCHAR[100],
  PRIMARY KEY (exhibit_id)
);

CREATE TABLE Room (
  room_id INT,
  name VARCHAR[100],
  PRIMARY KEY (room_id)
);

CREATE TABLE Room_connection (
  room1_id INT,
  room2_id INT,
  FOREIGN KEY (room1_id) REFERENCES Room(room_id),
  FOREIGN KEY (room2_id) REFERENCES Room(room_id)
);


CREATE TABLE Room_Exhibit (
  room_id INT,
  exhibit_id INT,
  FOREIGN KEY (room_id) REFERENCES Room(room_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
);

CREATE TABLE QR_code (
  QR_id INT,
  exhibit_id INT,
  room_id INT,
  QR_img_path  path,
  PRIMARY KEY (QR_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
  FOREIGN KEY (room_id) REFERENCES Room(room_id)
);

CREATE TABLE Images (
  image_id INT,
  exhibit_id INT,
  alt_text VARCHAR[100],
  img_path path,
  PRIMARY KEY (image_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
);

CREATE TABLE Tags (
  tag_id INT,
  exhibit_id INT,
  PRIMARY KEY (tag_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
);

CREATE TABLE Eras (
  era_id INT,
  era_name VARCHAR[100],
  PRIMARY KEY (era_id)
);

CREATE TABLE Themes (
  theme_id INT,
  thm_name VARCHAR[100],
  PRIMARY KEY (theme_id)
);

CREATE TABLE TagEra (
  tag_id INT,
  era_id INT,
  FOREIGN KEY (tag_id) REFERENCES Tags(tag_id),
  FOREIGN KEY (era_id) REFERENCES Eras(era_id)
);

CREATE TABLE TagTheme (
  tag_id INT,
  theme_id INT,
  FOREIGN KEY (tag_id) REFERENCES Tags(tag_id),
  FOREIGN KEY (theme_id) REFERENCES Themes(theme_id)
);

CREATE TABLE Session (
  session_id INT,
  PRIMARY KEY (session_id)
);

CREATE TABLE QR_Scan (
  session_id INT,
  room_id INT,
  exhibit_id INT,
  scanned_at TIMESTAMP,
  FOREIGN KEY (session_id) REFERENCES Session(session_id),
  FOREIGN KEY (room_id) REFERENCES Room(room_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id)
);

CREATE TABLE Feedback (
  feedback_id INT,
  exhibit_id INT,
  session_id INT,
  comment VARCHAR[200],
  rating INT,
  made_at TIMESTAMP,
  PRIMARY KEY (feedback_id),
  FOREIGN KEY (exhibit_id) REFERENCES Exhibits(exhibit_id),
  FOREIGN KEY (session_id) REFERENCES Session(session_id)
);

CREATE TABLE Related_exhibits (
  relation_id INT,
  exhibit1_id INT,
  exhibit2_id INT,
  PRIMARY KEY (relation_id),
  FOREIGN KEY (exhibit1_id) REFERENCES Exhibits(exhibit_id),
  FOREIGN KEY (exhibit2_id) REFERENCES Exhibits(exhibit_id)
)







