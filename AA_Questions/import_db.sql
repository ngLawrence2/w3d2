PRAGMA foreign_keys = ON;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE questions_follows( 
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  body TEXT,
  question_id INTEGER,
  parent_id INTEGER,
  author_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
("Bob", "lastname"),
("Sam", "Othername"),
("John", "OtheroOTERNAME");

INSERT INTO
  questions(title, body, author_id)
VALUES
  ("Question1", "qqqqqq", 1),
  ("Q2", "question", 2),
  ("Q3", "question", 3),
  ("Q4", "QQQQQ", 1),
  ("Q5", "QQQQQ", 1),
  ("Q6", "QQQQQ", 1);

INSERT INTO
  questions_follows(question_id, user_id)
VALUES
(1,2),
(1,3),
(2,1);

INSERT INTO 
  replies(body,question_id,parent_id,author_id)
VALUES
  ('reply', 1, null, 2),
  ('replytoreply', null , 1 , 3);
  
INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (2,4),
  (3,1),
  (2,1);
  

