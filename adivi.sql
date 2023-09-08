CREATE DATABASE guessing_game;

\c  guessing_game;

CREATE TABLE player (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(40)
)

CREATE TABLE puntuaction (
    id SERIAL,
    date TIMESTAMP,
    puntuaction INT,
    Foreign Key (puntuaction) REFERENCES player(id)
)