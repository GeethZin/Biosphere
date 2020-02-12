------------------------------------------------
-- Drops the existing database.
------------------------------------------------
USE [master];
GO
IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'BIOSPHERE')
    DROP DATABASE BIOSPHERE;
GO

------------------------------------------------
-- Creates the database and the schema.
------------------------------------------------
CREATE DATABASE BIOSPHERE;
GO
USE BIOSPHERE;
GO

------------------------------------------------
-- Creates the database schema.
------------------------------------------------
CREATE SCHEMA [Bio] AUTHORIZATION [dbo];
GO

------------------------------------------------
-- TABLE:  [Bio].[Place]
-- PREFIX: pl
-- Stores places where authors can be born and
-- publications can be made.
------------------------------------------------
CREATE TABLE [Bio].[Place] (
	pl_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	pl_country CHAR(2) NOT NULL, -- Country. Ex.: US, JA, CH, BR, etc...
	pl_region VARCHAR(50) NULL, -- Region, State, Province, etc...
	pl_city VARCHAR(50) NULL, -- City
	PRIMARY KEY (pl_id)
);
GO


------------------------------------------------
-- TABLE:  [Bio].[Author]
-- PREFIX: au
-- Stores information about authors.
------------------------------------------------
CREATE TABLE [Bio].[Author] (
	au_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	au_fname VARCHAR(50) NOT NULL, -- first name
	au_mname VARCHAR(50) NULL, -- middle name
	au_lname VARCHAR(50) NOT NULL, -- last name
	au_birthdate DATE NULL, -- birthdate
	au_birthplace INT NULL, -- place of birth FK -> [Bio].[Place]
	PRIMARY KEY (au_id),
	CONSTRAINT fk_au_born_at FOREIGN KEY (au_birthplace) REFERENCES [Bio].[Place]
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Publication]
-- PREFIX: pu
-- Stores information about publications.
------------------------------------------------
CREATE TABLE [Bio].[Publication] (
	pu_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	pu_year NUMERIC(4,0) NOT NULL,
	pu_title VARCHAR(300) NOT NULL,
	pu_page_start INT NULL,
	pu_page_end INT NULL,
	pu_publisher VARCHAR(300) NULL,
	pu_ex_source VARCHAR(10) NULL,
	pu_ex_code VARCHAR(30) NULL,
	pu_pub_at INT NULL, -- place of publication FK -> [Bio].[Place]
	PRIMARY KEY (pu_id),
	CONSTRAINT fk_pu_pub_at FOREIGN KEY (pu_pub_at) REFERENCES [Bio].[Place],
	-- either this publication has no page information, only the first page or both but end > start
	CONSTRAINT chk_pu_pages CHECK ((pu_page_end IS NULL) OR ((pu_page_start IS NOT NULL) AND (pu_page_end > pu_page_start))),
	-- either this publication has the external source CODE and ID, or neither
	CONSTRAINT chk_pu_ex_id_null CHECK (((pu_ex_code IS NULL) AND (pu_ex_source IS NULL)) OR ((pu_ex_code IS NOT NULL) AND (pu_ex_source IS NOT NULL)))
);
GO


------------------------------------------------
-- TABLE:  [Bio].[Au_Writes_Pu]
-- Stores the M:N relationship "authors write publications".
------------------------------------------------
CREATE TABLE [Bio].[Au_Writes_Pu] (
	au_id INT NOT NULL, -- author FK -> [Bio].[Author]
	pu_id INT NOT NULL, -- pubication FK -> [Bio].[Publication]
	PRIMARY KEY (au_id, pu_id),
	CONSTRAINT fk_au_writes_pu_au FOREIGN KEY (au_id) REFERENCES [Bio].[Author],
	CONSTRAINT fk_au_writes_pu_pu FOREIGN KEY (pu_id) REFERENCES [Bio].[Publication]
);
GO


------------------------------------------------
-- TABLE:  [Bio].[CommonName]
-- PREFIX: cn
-- Stores information about common names of species.
------------------------------------------------
CREATE TABLE [Bio].[CommonName] (
	cn_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	cn_name VARCHAR(50) NOT NULL, -- the value of the attribute
	PRIMARY KEY (cn_id),
	-- common names are unique
	CONSTRAINT chk_cn_name_unique UNIQUE (cn_name)
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Location]
-- PREFIX: lo
-- Stores information about locations of species.
------------------------------------------------
CREATE TABLE [Bio].[Location] (
	lo_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	lo_name VARCHAR(50) NOT NULL, -- the value of the attribute
	PRIMARY KEY (lo_id),
	-- location names are unique
	CONSTRAINT chk_lo_name_unique UNIQUE (lo_name)
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Status]
-- PREFIX: st
-- Stores information about conservation status.
-- This is an enumerated type with fixed values.
------------------------------------------------
CREATE TABLE [Bio].[Status] (
	st_id TINYINT IDENTITY(0,1) NOT NULL, -- automatically generated id
	st_name VARCHAR(50) NOT NULL, -- the value of the attribute
	PRIMARY KEY (st_id),
	-- statuses are unique
	CONSTRAINT chk_st_name_unique UNIQUE (st_name)
)


------------------------------------------------
-- TABLE:  [Bio].[Species]
-- PREFIX: sp
-- Stores information about species.
------------------------------------------------
CREATE TABLE [Bio].[Species] (
	sp_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	sp_genus VARCHAR(50) NOT NULL,
	sp_species VARCHAR(50) NOT NULL,
	sp_subspecies VARCHAR(50) NULL,
	sp_behaviour VARCHAR(255) NULL,
	sp_habitat VARCHAR(255) NULL,
	sp_niche VARCHAR(255) NULL,
	sp_pub_year INT NULL,
	sp_status TINYINT NOT NULL, -- conservation status FK -> [Bio].[Status]
	PRIMARY KEY (sp_id),
	CONSTRAINT fk_sp_status FOREIGN KEY (sp_status) REFERENCES [Bio].[Status]
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Sp_Has_Cn]
-- Stores the M:N relationship "species have common names".
------------------------------------------------
CREATE TABLE [Bio].[Sp_Has_Cn] (
	sp_id INT NOT NULL, -- species FK -> [Bio].[Species]
	cn_id INT NOT NULL, -- species FK -> [Bio].[CommonName]
	PRIMARY KEY (sp_id, cn_id),
	CONSTRAINT fk_sp_has_cn_sp FOREIGN KEY (sp_id) REFERENCES [Bio].[Species],
	CONSTRAINT fk_sp_has_cn_cn FOREIGN KEY (cn_id) REFERENCES [Bio].[CommonName]
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Sp_Has_Lo]
-- Stores the M:N relationship "species have locations".
------------------------------------------------
CREATE TABLE [Bio].[Sp_Has_Lo] (
	sp_id INT NOT NULL, -- species FK -> [Bio].[Species]
	lo_id INT NOT NULL, -- location FK -> [Bio].[Location]
	PRIMARY KEY (sp_id, lo_id),
	CONSTRAINT fk_sp_has_lo_sp FOREIGN KEY (sp_id) REFERENCES [Bio].[Species],
	CONSTRAINT fk_sp_has_lo_lo FOREIGN KEY (lo_id) REFERENCES [Bio].[Location]
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Au_Describes_Sp]
-- Stores the M:N relationship "authors describe species".
------------------------------------------------
CREATE TABLE [Bio].[Au_Describes_Sp] (
	au_id INT NOT NULL, -- author FK -> [Bio].[Author]
	sp_id INT NOT NULL, -- species FK -> [Bio].[Species]
	PRIMARY KEY (au_id, sp_id),
	CONSTRAINT fk_au_describes_sp_au FOREIGN KEY (au_id) REFERENCES [Bio].[Author],
	CONSTRAINT fk_au_describes_sp_sp FOREIGN KEY (sp_id) REFERENCES [Bio].[Species]
);

------------------------------------------------
-- TABLE:  [Bio].[Sp_References_Pu]
-- Stores the M:N relationship "species reference pu".
------------------------------------------------
CREATE TABLE [Bio].[Sp_References_Pu] (
	sp_id INT NOT NULL, -- species FK -> [Bio].[Species]
	pu_id INT NOT NULL, -- publication FK -> [Bio].[Publication]
	PRIMARY KEY (sp_id, pu_id),
	CONSTRAINT fk_sp_references_au_sp FOREIGN KEY (sp_id) REFERENCES [Bio].[Species],
	CONSTRAINT fk_sp_references_au_pu FOREIGN KEY (pu_id) REFERENCES [Bio].[Publication]
);


------------------------------------------------
-- TABLE:  [Bio].[EcoInterType]
-- PREFIX: it
-- Stores information about types of ecological interactions.
--
-- For example:
--  * the ecological interaction type 'predation' happens when one
--    species eats another; it is an unbalanced interaction.
--  * the ecological interaction type 'mutualism' happens when two
--    species help one another; it is a beneficial interaction.
------------------------------------------------
CREATE TABLE [Bio].[EcoInterType] (
	it_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	it_name VARCHAR(50) NOT NULL, -- the name of the interaction type
	it_mode NUMERIC(1,0) NOT NULL, -- 0: neutral, 1: beneficial, -1: unbanlanced
	it_desc VARCHAR(255) NOT NULL,  -- brief description
	PRIMARY KEY (it_id),
	CONSTRAINT chk_it_name_unique UNIQUE (it_name),
	CONSTRAINT chk_it_mode CHECK (it_mode IN (-1, 0, 1)),
);
GO

------------------------------------------------
-- TABLE:  [Bio].[EcoInterGroup]
-- PREFIX: eg
--
-- Stores information about groups of ecological interactions.
--
-- Many species can form a group of interaction, for a given
-- interaction type. For example:
--  * Man and Dog form a group, in mutualism
--  * Man and Chicken form a group, in predation (man eats chicken)
--
-- This table just stores the group ID and its type.
------------------------------------------------
CREATE TABLE [Bio].[EcoInterGroup] (
	eg_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	eg_type INT NOT NULL, -- type of interaction FK -> [Bio].[EcoInterType]
	eg_desc VARCHAR(255) NOT NULL,  -- brief description
	PRIMARY KEY (eg_id),
	CONSTRAINT fk_eg_type FOREIGN KEY (eg_type) REFERENCES [Bio].[EcoInterType]
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Sp_Participates_Eg]
-- Stores the M:N relationship "species participates in ecological interaction group".
------------------------------------------------
CREATE TABLE [Bio].[Sp_Participates_Eg] (
	sp_id INT NOT NULL, -- species FK -> [Bio].[Species]
	eg_id INT NOT NULL, -- group FK -> [Bio].[EcoInterGroup]
	PRIMARY KEY (sp_id, eg_id),
	CONSTRAINT fk_sp_participates_eg_sp FOREIGN KEY (sp_id) REFERENCES [Bio].[Species],
	CONSTRAINT fk_sp_participates_eg_eg FOREIGN KEY (eg_id) REFERENCES [Bio].[EcoInterGroup]
);
GO


------------------------------------------------
-- TABLE:  [Bio].[User]
-- PREFIX: us
--
-- Stores information about users of the system.
--
-- Two triggers make sure that the user's birthdate
-- and the corresponding author profile match.
------------------------------------------------
CREATE TABLE [Bio].[User] (
	us_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id
	us_email VARCHAR(100) NOT NULL,
	us_name VARCHAR(100) NOT NULL,
	us_birthdate DATE NOT NULL,
	us_password VARCHAR(30) NOT NULL,
	us_author_profile INT NULL, -- author associated with this user FK -> [Bio].[Author]
	PRIMARY KEY (us_id),
	-- users must have unique email
	CONSTRAINT chk_us_email_unique UNIQUE (us_email),
	-- each user-author association must be unique
	CONSTRAINT chk_us_author_profile UNIQUE (us_author_profile),
	CONSTRAINT fk_us_author_profile FOREIGN KEY (us_author_profile) REFERENCES [Bio].[Author]
);
GO

CREATE TRIGGER [Bio].[CheckBirthdateUser] ON [Bio].[User]
AFTER INSERT, UPDATE AS
IF EXISTS (
	SELECT us_id
	FROM [Bio].[User], [Bio].[Author]
	WHERE au_id = us_author_profile AND us_birthdate != au_birthdate
)
	ROLLBACK TRANSACTION
GO

CREATE TRIGGER [Bio].[CheckBirthdateAuthor] ON [Bio].[Author]
AFTER UPDATE AS
IF EXISTS (
	SELECT us_id
	FROM [Bio].[User], [Bio].[Author]
	WHERE au_id = us_author_profile AND us_birthdate != au_birthdate
) BEGIN
	RAISERROR ('User and author profile birthdate don''t match.', 16, 1);
	ROLLBACK TRANSACTION
END
GO


------------------------------------------------
-- TABLE:  [Bio].[Comment]
-- PREFIX: co
--
-- Stores information about comments on species.
--
-- Two triggers make sure that the user's birthdate
-- and the corresponding author profile match.
------------------------------------------------
CREATE TABLE [Bio].[Comment] (
	us_id INT NOT NULL, -- user FK -> [Bio].[User]
	sp_id INT NOT NULL, -- user FK -> [Bio].[Species]
	co_timestamp DATETIME NOT NULL, -- time of the comment
	co_content VARCHAR(500) NOT NULL,
	-- the original comment that we are replying to FK -> [Bio].[User]
	co_orig_us INT NULL,
	co_orig_sp INT NULL,
	co_orig_ts DATETIME NULL,
	PRIMARY KEY (us_id, sp_id, co_timestamp),
	CONSTRAINT fk_co_orig FOREIGN KEY (co_orig_us, co_orig_sp, co_orig_ts) REFERENCES [Bio].[Comment],
	-- it's not possible to reply to a comment in a different species
	-- than the original comment
	CONSTRAINT chk_co_orig_sp CHECK ((co_orig_sp IS NULL) OR (co_orig_sp = sp_id))
);
GO



------------------------------------------------
-- TABLE:  [Bio].[Group]
-- PREFIX: gr
--
-- Stores information about groups.
------------------------------------------------
CREATE TABLE [Bio].[Group] (
	gr_name VARCHAR(30) NOT NULL,
	gr_desc VARCHAR(100) NULL,
	PRIMARY KEY (gr_name),
	-- group names must not be empty
	CONSTRAINT chk_gr_name CHECK (LEN(gr_name) > 0)
);
GO

------------------------------------------------
-- TABLE:  [Bio].[Us_Member_Gr]
-- Stores the M:N relationship "user is member of group".
------------------------------------------------
CREATE TABLE [Bio].[Us_Member_Gr] (
	us_id INT NOT NULL, -- user FK -> [Bio].[User]
	gr_name VARCHAR(30) NOT NULL, -- user FK -> [Bio].[Group]
	PRIMARY KEY (us_id, gr_name),
	CONSTRAINT fk_us_member_gr_us FOREIGN KEY (us_id) REFERENCES [Bio].[User],
	CONSTRAINT fk_us_member_gr_gr FOREIGN KEY (gr_name) REFERENCES [Bio].[Group]
);
GO


------------------------------------------------
-- TABLE:  [Bio].[Gr_Access_Sp]
-- PREFIX: ac
--
-- Stores permission information about groups.
--
-- A [Bio].[Species] foreign key defines the CONTEXT of the access:
--    * if genus is NULL, the context is the whole database
--    * if genus is not NULL, but species is NULL, the context is any
--      species in the given genus
--    * if genus is not NULL, species is not NULL, but subspecies is NULL,
--      the context is any subspecies in the given genus and species.
--
-- The LEVEL of access can be CREATE(0), DELETE(1), MODIFY(2)
--
-- For example, considering (genus, species, subpecies, level) format, the following
-- permissions have the given meaning:
--
--  (NULL, NULL, NULL, 0) -> the group can CREATE any species on the database
--  (NULL, NULL, NULL, 1) -> the group can DELETE any species on the database
--  (NULL, NULL, NULL, 2) -> the group can MODIFY any species on the database
--  ('Homo', NULL, NULL, 2) -> the group can MODIFY any species on the genus 'Homo'
--  ('Canis', 'lupus', NULL, 0) -> the group can CREATE any subspecies of 'Canis lupus'
--  ('Canis', 'lupus', 'familiaris', 1) -> the group can DELETE the subspecies 'Canis lupus familiaris'
------------------------------------------------
CREATE TABLE [Bio].[Gr_Access_Sp] (
	ac_id INT IDENTITY(1,1) NOT NULL, -- automatically generated id, to avoid problems
	ac_group VARCHAR(30) NOT NULL, -- user FK -> [Bio].[Group]
	ac_ctx_genus VARCHAR(50) NULL, -- context.genus (FK, with trigger) -> [Bio].[Species].[sp_genus]
	ac_ctx_species VARCHAR(50) NULL, -- context.species (FK, with trigger) -> [Bio].[Species].[sp_species]
	ac_ctx_subspecies VARCHAR(50) NULL, -- context.subspecies (FK, with trigger) -> [Bio].[Species].[sp_subspecies]
	ac_level NUMERIC(1,0) NOT NULL, -- 0: create, 1: delete, 2: modify
	PRIMARY KEY (ac_id),
	CONSTRAINT fk_ac_group FOREIGN KEY (ac_group) REFERENCES [Bio].[Group],
	CONSTRAINT chk_ctx_unique UNIQUE (ac_group, ac_ctx_genus, ac_ctx_species, ac_ctx_subspecies),
	CONSTRAINT chk_level CHECK (ac_level IN (0, 1, 2)),
);
GO

CREATE TRIGGER [Bio].[CheckGroupAccess] ON [Bio].[Gr_Access_Sp]
AFTER INSERT, UPDATE AS
	-- Checks if there is any invalid reference for genus, species or subspecies
	IF NOT EXISTS (
		SELECT sp_id
		FROM [Bio].[Species], [Bio].[Gr_Access_Sp]
		WHERE (
			((ac_ctx_genus IS NULL) OR (ac_ctx_genus = sp_genus)) AND
			((ac_ctx_species IS NULL) OR (ac_ctx_species = sp_species)) AND
			((ac_ctx_subspecies IS NULL) OR (ac_ctx_subspecies = sp_subspecies))
		)
	) BEGIN
		RAISERROR ('Invalid genus, species or subspecies.', 16, 1);
		ROLLBACK TRANSACTION
	END
GO


INSERT INTO [Bio].[Status](st_name)
VALUES
('not evaluated'), -- 0 and so on
('domesticated'),
('least concern'),
('near threatened'),
('vulnerable'),
('endangered'),
('critically endangered'),
('extinct in the wild'),
('extinct'),
('data deficient');


-- Species (sp_genus, sp_species, sp_subspecies, sp_behaviour, sp_habitat, sp_niche, sp_pub_year, sp_status)
INSERT INTO [Bio].[Species] VALUES ('Panthera', 'leo', NULL, 'Sleeps tonight.', 'Savannah', NULL, 1735, 4);
INSERT INTO [Bio].[CommonName] VALUES ('Lion');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (1, 1) -- is also called Lion
INSERT INTO [Bio].[Location] VALUES ('Africa');
INSERT INTO [Bio].[Sp_Has_Lo] VALUES (1, 1) -- lives in Africa
INSERT INTO [Bio].[Place] VALUES ('SE', 'Stenbrohult', 'Råshult');
INSERT INTO [Bio].[Author] VALUES ('Carl', NULL, 'Linnaeus', '1707-05-23', 1);
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (1, 1) -- described by Linnaeus
INSERT INTO [Bio].[Place] VALUES ('NL', 'South Holland', 'Leide');
INSERT INTO [Bio].[Publication] VALUES (1735, 'Systema Naturae', NULL, NULL, 'Haak', NULL, NULL, 2)
INSERT INTO [Bio].[Au_Writes_Pu] VALUES (1, 1)
INSERT INTO [Bio].[Sp_References_Pu] VALUES (1, 1) -- references publication 'Systema Naturae'

INSERT INTO [Bio].[Species] VALUES ('Eudorcas', 'thomsonii', NULL, 'Eats grass.', 'Savannah', NULL, 1884, 2);
INSERT INTO [Bio].[CommonName] VALUES ('Thompson''s gazelle');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (2, 2) -- is also called Thompson's gazelle
INSERT INTO [Bio].[Sp_Has_Lo] VALUES (2, 1) -- lives in Africa
INSERT INTO [Bio].[Place] VALUES ('DE', NULL, 'Esslingen');
INSERT INTO [Bio].[Author] VALUES ('Albert', 'Charles Lewis Gotthilf', 'Günther', '1830-10-03', 2);
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (2, 2) -- described by Günther
INSERT INTO [Bio].[Publication] VALUES (1884, 'Note on some East-African Antelopes supposed to be new', 425, 429, 'Annals and Magazine of Natural History', NULL, NULL, NULL)
INSERT INTO [Bio].[Au_Writes_Pu] VALUES (2, 2)
INSERT INTO [Bio].[Sp_References_Pu] VALUES (2, 2) -- references publication 'Note on...'

INSERT INTO [Bio].[Species] VALUES ('Homo', 'sapiens', 'sapiens', 'Usually very smart.', 'Earth', NULL, 1735, 2);
INSERT INTO [Bio].[CommonName] VALUES ('Man'), ('Human');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (3, 3), (3, 4) -- is also called Man and Human
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (1, 3) -- described by Linnaeus
INSERT INTO [Bio].[Sp_References_Pu] VALUES (3, 1) -- references publication 'Systema Naturae'

INSERT INTO [Bio].[Species] VALUES ('Gallus', 'gallus', 'domesticus', 'Happy on the corn.', 'Earth', NULL, 1735, 1);
INSERT INTO [Bio].[CommonName] VALUES ('Chicken');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (4, 5) -- is also called Chicken
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (1, 4) -- described by Linnaeus
INSERT INTO [Bio].[Sp_References_Pu] VALUES (4, 1) -- references publication 'Systema Naturae'

INSERT INTO [Bio].[Species] VALUES ('Xylocopa', 'violacea', NULL, 'Buzzes.', 'Earth', NULL, 1735, 0);
INSERT INTO [Bio].[CommonName] VALUES ('Carpenter bee');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (5, 6) -- is also called Carpenter bee
INSERT INTO [Bio].[Location] VALUES ('Europe'), ('Asia');
INSERT INTO [Bio].[Sp_Has_Lo] VALUES (5, 2), (5, 3) -- lives in Europe and Asia
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (1, 5) -- described by Linnaeus
INSERT INTO [Bio].[Sp_References_Pu] VALUES (5, 1) -- references publication 'Systema Naturae'

INSERT INTO [Bio].[Species] VALUES ('Hylocereus', 'undatus', NULL, 'Delicious.', 'Tropical zones', NULL, 1918, 2);
INSERT INTO [Bio].[CommonName] VALUES ('Dragon fruit'), ('Pitahaya');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (6, 7), (6, 8) -- is also called Dragon fruit and Pitahaya
INSERT INTO [Bio].[Place] VALUES ('US', 'New York', 'New Dorp');
INSERT INTO [Bio].[Author] VALUES ('Nathaniel', 'Lord', 'Britton', '1859-11-15', 4);
INSERT INTO [Bio].[Place] VALUES ('US', 'Indiana', 'Union County');
INSERT INTO [Bio].[Author] VALUES ('Joseph', 'Nelson', 'Rose', '1862-11-04', 5);
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (3, 6), (4, 6) -- described by Britton and Rose
INSERT INTO [Bio].[Place] VALUES ('US', 'New York', 'New York');
INSERT INTO [Bio].[Publication] VALUES (1918, 'Flora of Bermuda', NULL, NULL, 'Charles Scribner''s Sons', NULL, NULL, 6)
INSERT INTO [Bio].[Au_Writes_Pu] VALUES (3, 3), (4, 3);
INSERT INTO [Bio].[Sp_References_Pu] VALUES (6, 1) -- references publication 'Flora of Bermuda'

INSERT INTO [Bio].[Species] VALUES ('Canis', 'lupus', 'familiaris', 'Is a good boy!', 'Earth', NULL, 1735, 1);
INSERT INTO [Bio].[CommonName] VALUES ('Dog');
INSERT INTO [Bio].[Sp_Has_Cn] VALUES (7, 9) -- is also called Dog
INSERT INTO [Bio].[Au_Describes_Sp] VALUES (1, 7) -- described by Linnaeus
INSERT INTO [Bio].[Sp_References_Pu] VALUES (7, 1) -- references publication 'Systema Naturae'

INSERT INTO [Bio].[EcoInterType]
VALUES
('predation', -1, 'when one species eats other species'),
('pollination', 1, 'when a species spreads polen for another species'),
('mutualism', 1, 'when two or more species co-operate for mutual benefit'),
('commensalism', 0, 'when a species benefits from another, without causing harm'),
('parasitism', -1, 'when a species benefits from living inside another, causing some harm'),
('amensalism', -1, 'when a species harms another, without getting any benefit'),
('competition', -1, 'when two or more species compete for the same resource');

INSERT INTO [Bio].[EcoInterGroup]
VALUES
-- predation
(1, 'lions eats gazelle'),
(1, 'human eats chicken'),
-- pollination
(2, 'carpenter bee pollinates pitahaya'),
-- mutualism
(3, 'human and dog live together');

-- (species, eco group)
INSERT INTO [Bio].[Sp_Participates_Eg]
VALUES
-- lions eats gazelle
(1, 1),
(2, 1),
-- human eats chicken
(3, 2),
(4, 2),
-- carpenter bee pollinates pitahaya
(5, 3),
(6, 3),
-- human and dog live together
(3, 4),
(7, 4)
GO
