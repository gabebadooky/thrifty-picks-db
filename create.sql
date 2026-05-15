-- Schema: pickem
CREATE SCHEMA IF NOT EXISTS pickem;


/************************************** 
* Table: pickem.conference
**************************************/
CREATE TABLE IF NOT EXISTS pickem.conference (
	id                      VARCHAR(25)     PRIMARY KEY,
	name                    VARCHAR(50)     NOT NULL,
	abbreviation            VARCHAR(10)     NOT NULL,
	power_conference        BOOLEAN         NOT NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_conference_power_conference ON pickem.conference (power_conference);
/*************************************/


/**************************************
* Table: pickem.location
**************************************/
CREATE TABLE IF NOT EXISTS pickem.location (
	id                      VARCHAR(25)     PRIMARY KEY,
	stadium                 VARCHAR(100)    NOT NULL,
	city                    VARCHAR(50)     NOT NULL,
	state                   VARCHAR(25)     NOT NULL,
	latitude                REAL           	NOT NULL,
	longitude               REAL           	NOT NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
/*************************************/


/**************************************
* Table: pickem.maintenance
**************************************/
CREATE TABLE IF NOT EXISTS pickem.maintenance (
	id                      BIGINT      	GENERATED ALWAYS AS IDENTITY,
	flag                    BOOLEAN         NOT NULL,
	created_at              TIMESTAMP       NOT NULL
);
/*************************************/


/**************************************
* Table: pickem.scoring
**************************************/
CREATE TABLE IF NOT EXISTS pickem.scoring (
	confidence              CHAR(1)         PRIMARY KEY,
	reward                  SMALLINT        NOT NULL,
	penalty                 SMALLINT        NOT NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
/*************************************/


/**************************************
* Table: pickem.user
**************************************/
CREATE TABLE IF NOT EXISTS pickem.user (
	id                      SERIAL          PRIMARY KEY,
	username                VARCHAR(75)     NOT NULL,
	display_name            VARCHAR(50)     NOT NULL,
	favorite_team           VARCHAR(100)    NOT NULL,
	notification_preference CHAR(1)         NOT NULL,
	email_address           VARCHAR(75)     NOT NULL,
	phone                   VARCHAR(10)     NOT NULL,
	created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_username ON pickem.user (username);
/*************************************/

/**************************************
* Table: pickem.team
**************************************/
CREATE TABLE IF NOT EXISTS pickem.team (
	id                      VARCHAR(100)    PRIMARY KEY,
	league                  VARCHAR(25)     NOT NULL,
	espn_code               VARCHAR(50)     NOT NULL,
	cbs_code                VARCHAR(50)     NOT NULL,
	fox_code                VARCHAR(50)     NOT NULL,
	vegas_code              VARCHAR(50)     NULL,
	conference	            VARCHAR(25)     NOT NULL,
	division                VARCHAR(50)     NOT NULL,
	name                    VARCHAR(50)     NOT NULL,
	mascot                  VARCHAR(50)     NOT NULL,
	logo_url                VARCHAR(100)    NOT NULL,
	dark_logo_url           VARCHAR(100)    NOT NULL,
	primary_color           VARCHAR(10)     NOT NULL,
	alternate_color         VARCHAR(10)     NOT NULL,
	ranking                 SMALLINT        NOT NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_team_conference FOREIGN KEY (conference) REFERENCES pickem.conference(id)
);

CREATE INDEX IF NOT EXISTS idx_team_conference ON pickem.team (conference);
CREATE INDEX IF NOT EXISTS idx_team_ranking ON pickem.team (ranking);
/*************************************/


/**************************************
* Table: pickem.team_record
**************************************/
CREATE TABLE IF NOT EXISTS pickem.team_record (
	team                    VARCHAR(100)    NOT NULL,
	record_type                    VARCHAR(10)     NOT NULL,
	wins                    SMALLINT        NULL,
	losses                  SMALLINT        NULL,
	ties                    SMALLINT        NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (team, record_type),
	CONSTRAINT fk_team_record_team FOREIGN KEY (team) REFERENCES pickem.team(id)
);

CREATE INDEX IF NOT EXISTS idx_team_record_team ON pickem.team_record (team);
/*************************************/


/**************************************
* Table: pickem.team_note
**************************************/
CREATE TABLE IF NOT EXISTS pickem.team_note (
	user_id                 INTEGER         NOT NULL,
	team                    VARCHAR(100)    NOT NULL,
	text                    TEXT            NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (user_id, team),
	CONSTRAINT fk_team_note_user FOREIGN KEY (user_id) REFERENCES pickem.user(id),
	CONSTRAINT fk_team_note_team FOREIGN KEY (team) REFERENCES pickem.team(id)
);

CREATE INDEX IF NOT EXISTS idx_team_note_user ON pickem.team_note (user_id);
/*************************************/


/**************************************
* Table: pickem.game
**************************************/
CREATE TABLE IF NOT EXISTS pickem.game (
	id                      VARCHAR(100)    PRIMARY KEY,
	league                  VARCHAR(25)     NOT NULL,
	week                    SMALLINT        NOT NULL,
	season                  SMALLINT        NOT NULL,
	espn_code               VARCHAR(50)     NOT NULL,
	cbs_code                VARCHAR(50)     NOT NULL,
	fox_code                VARCHAR(50)     NOT NULL,
	vegas_code              VARCHAR(50)     NULL,
	away_team               VARCHAR(100)    NOT NULL,
	home_team               VARCHAR(100)    NOT NULL,
	kickoff_utc             TIMESTAMP       NOT NULL,
	broadcast               VARCHAR(25)     NOT NULL,
	location             	VARCHAR(25)     NOT NULL,
	finished                BOOLEAN         NOT NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_game_away_team FOREIGN KEY (away_team) REFERENCES pickem.team(id),
	CONSTRAINT fk_game_home_team FOREIGN KEY (home_team) REFERENCES pickem.team(id),
	CONSTRAINT fk_game_location FOREIGN KEY (location) REFERENCES pickem.location(id)
);

CREATE INDEX IF NOT EXISTS idx_game_week ON pickem.game (week);
CREATE INDEX IF NOT EXISTS idx_game_away_team ON pickem.game (away_team);
CREATE INDEX IF NOT EXISTS idx_game_home_team ON pickem.game (home_team);
CREATE INDEX IF NOT EXISTS idx_game_finished ON pickem.game (finished);
/*************************************/


/**************************************
* Table: pickem.forecast
**************************************/
CREATE TABLE IF NOT EXISTS pickem.forecast (
	location             	VARCHAR(25)    	NOT NULL,
	timestamp_utc           TIMESTAMP       NOT NULL,
	temperature             REAL            NULL,
	feels_like              REAL            NULL,
	humidity                REAL            NULL,
	visibility              REAL            NULL,
	wind_speed              REAL            NULL,
	short_description       varchar(100)    NULL,
	long_description        varchar(100)    NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (location, timestamp_utc),
	CONSTRAINT fk_forecast_location FOREIGN KEY (location) REFERENCES pickem.location(id)
	-- CONSTRAINT fk_forecast_gameime FOREIGN KEY (timestamp_utc) REFERENCES pickem.game(kickoff_utc)
);
/*************************************/


/**************************************
* Table: pickem.betting_odds
**************************************/
CREATE TABLE IF NOT EXISTS pickem.betting_odds (
	game                 	VARCHAR(100)    NOT NULL,
	team                 	VARCHAR(100)    NOT NULL,
	source                  VARCHAR(10)     NOT NULL,
	over_under              REAL            NULL,
	moneyline               SMALLINT        NULL,
	spread                  REAL            NULL,
	win_probability         REAL            NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (game, team, source),
	CONSTRAINT fk_betting_odds_game FOREIGN KEY (game) REFERENCES pickem.game(id),
	CONSTRAINT fk_betting_odds_team FOREIGN KEY (team) REFERENCES pickem.team(id)
);

CREATE INDEX IF NOT EXISTS idx_betting_odds_team ON pickem.betting_odds (team);
/*************************************/


/**************************************
* Table: pickem.box_score
**************************************/
CREATE TABLE IF NOT EXISTS pickem.box_score (
	game                 	VARCHAR(100)    NOT NULL,
	team                 	VARCHAR(100)    NOT NULL,
	quarter1                SMALLINT        NULL,
	quarter2                SMALLINT        NULL,
	quarter3                SMALLINT        NULL,
	quarter4                SMALLINT        NULL,
	overtime                SMALLINT        NULL,
	total                   SMALLINT        NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (game, team),
	CONSTRAINT fk_box_score_game FOREIGN KEY (game) REFERENCES pickem.game(id),
	CONSTRAINT fk_box_score_team FOREIGN KEY (team) REFERENCES pickem.team(id)
);

CREATE INDEX IF NOT EXISTS idx_box_score_team ON pickem.box_score (team);
/*************************************/


/**************************************
* Table: pickem.stat
**************************************/
CREATE TABLE IF NOT EXISTS pickem.stat (
	game                 	VARCHAR(100)    NOT NULL,
	team                 	VARCHAR(100)    NOT NULL,
	stat_type               VARCHAR(25)     NOT NULL,
	value                   REAL            NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	PRIMARY KEY (game, team, stat_type),
	CONSTRAINT fk_stat_game FOREIGN KEY (game) REFERENCES pickem.game(id),
	CONSTRAINT fk_stat_team FOREIGN KEY (team) REFERENCES pickem.team(id)
);

CREATE INDEX IF NOT EXISTS idx_stat_team ON pickem.stat (team);
/*************************************/


/**************************************
* Table: pickem.prediction
**************************************/
CREATE TABLE IF NOT EXISTS pickem.prediction (
	user_id                 INTEGER         NOT NULL,
	code                    VARCHAR(25)     NOT NULL,
	description             VARCHAR(100)   	NULL,
	selection               VARCHAR(100)    NULL,
	updated_at				TIMESTAMPTZ		NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (user_id, code),
	CONSTRAINT fk_prediction_user FOREIGN KEY (user_id) REFERENCES pickem.user(id)
);

CREATE INDEX IF NOT EXISTS idx_prediction_user ON pickem.prediction (user_id);
CREATE INDEX IF NOT EXISTS idx_prediction_code ON pickem.prediction (code);
/*************************************/


/**************************************
* Table: pickem.pick
**************************************/
CREATE TABLE IF NOT EXISTS pickem.pick (
	user_id                 INTEGER         NOT NULL,
	game                 	VARCHAR(100)    NOT NULL,
	team                 	VARCHAR(100)    NULL,
	confidence              CHAR(1)         NULL,
	updated_at              TIMESTAMPTZ     NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY (user_id, game),
	CONSTRAINT fk_pick_user FOREIGN KEY (user_id) REFERENCES pickem.user(id),
	CONSTRAINT fk_pick_game FOREIGN KEY (game) REFERENCES pickem.game(id),
	CONSTRAINT fk_pick_team FOREIGN KEY (team) REFERENCES pickem.team(id),
	CONSTRAINT fk_pick_confidence FOREIGN KEY (confidence) REFERENCES pickem.scoring(confidence)
);

CREATE INDEX IF NOT EXISTS idx_pick_user ON pickem.pick (user_id);
CREATE INDEX IF NOT EXISTS idx_pick_team ON pickem.pick (team);
/*************************************/



