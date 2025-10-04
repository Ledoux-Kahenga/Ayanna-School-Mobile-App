CREATE TABLE entreprises (
	nom VARCHAR(200) NOT NULL, 
	adresse TEXT, 
	numero_id VARCHAR(100), 
	devise VARCHAR(3), 
	telephone VARCHAR(20), 
	email VARCHAR(100), 
	logo BLOB, 
	timezone VARCHAR(50) NOT NULL, 
	date_creation DATETIME NOT NULL, 
	id INTEGER NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	server_id INTEGER,
	is_sync BOOLEAN DEFAULT 0,
	PRIMARY KEY (id)
)
CREATE TABLE responsables (
	id INTEGER NOT NULL, 
	nom VARCHAR(100), 
	code VARCHAR(5), 
	telephone VARCHAR(20), 
	adresse TEXT, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	server_id INTEGER,
	is_sync BOOLEAN DEFAULT 0,
	PRIMARY KEY (id), 
	UNIQUE (code)
)
CREATE TABLE classes_comptables (
	code VARCHAR(10), 
	nom VARCHAR(100) NOT NULL, 
	libelle VARCHAR(255) NOT NULL, 
	type VARCHAR(20) NOT NULL, 
	entreprise_id INTEGER NOT NULL, 
	actif BOOLEAN, 
	document VARCHAR(255), 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id)
)
CREATE TABLE sync_metadata (
	id INTEGER NOT NULL, 
	"key" VARCHAR(100) NOT NULL, 
	value VARCHAR(500), 
	updated_at DATETIME, 
	PRIMARY KEY (id), 
	UNIQUE ("key")
)
CREATE TABLE utilisateurs (
	nom VARCHAR(100) NOT NULL, 
	prenom VARCHAR(100) NOT NULL, 
	email VARCHAR(100) NOT NULL, 
	mot_de_passe_hash VARCHAR(255) NOT NULL, 
	role VARCHAR(50) NOT NULL, 
	actif BOOLEAN, 
	entreprise_id INTEGER NOT NULL, 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (email), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id)
)
CREATE TABLE annees_scolaires (
	id INTEGER NOT NULL, 
	nom VARCHAR(100) NOT NULL, 
	date_debut DATE NOT NULL, 
	date_fin DATE NOT NULL, 
	entreprise_id INTEGER NOT NULL, 
	en_cours INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id)
)
CREATE TABLE enseignants (
	id INTEGER NOT NULL, 
	matricule VARCHAR(50), 
	nom VARCHAR(100) NOT NULL, 
	prenom VARCHAR(100) NOT NULL, 
	sexe VARCHAR(10), 
	niveau VARCHAR(30), 
	discipline VARCHAR(50), 
	email VARCHAR(150), 
	telephone VARCHAR(20), 
	entreprise_id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id)
)
CREATE TABLE comptes_comptables (
	numero VARCHAR(20) NOT NULL, 
	nom VARCHAR(255) NOT NULL, 
	libelle VARCHAR(255) NOT NULL, 
	actif BOOLEAN, 
	classe_comptable_id INTEGER NOT NULL, 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(classe_comptable_id) REFERENCES classes_comptables (id)
)
CREATE TABLE licence (
	id INTEGER NOT NULL, 
	cle VARCHAR NOT NULL, 
	type VARCHAR NOT NULL, 
	date_activation DATETIME NOT NULL, 
	date_expiration DATETIME NOT NULL, 
	signature VARCHAR NOT NULL, 
	active BOOLEAN, 
	entreprise_id INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (cle), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id)
)
CREATE TABLE classes (
	id INTEGER NOT NULL, 
	code VARCHAR(3), 
	nom VARCHAR(100) NOT NULL, 
	niveau VARCHAR(50), 
	effectif INTEGER, 
	annee_scolaire_id INTEGER NOT NULL, 
	enseignant_id INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (code), 
	FOREIGN KEY(annee_scolaire_id) REFERENCES annees_scolaires (id), 
	FOREIGN KEY(enseignant_id) REFERENCES enseignants (id)
)
CREATE TABLE periodes (
	id INTEGER NOT NULL, 
	code VARCHAR(5), 
	nom VARCHAR(50) NOT NULL, 
	semestre INTEGER NOT NULL, 
	poids INTEGER, 
	date_debut DATE, 
	date_fin DATE, 
	annee_scolaire_id INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (code), 
	FOREIGN KEY(annee_scolaire_id) REFERENCES annees_scolaires (id)
)
CREATE TABLE frais_scolaires (
	id INTEGER NOT NULL, 
	nom VARCHAR(100) NOT NULL, 
	montant DECIMAL(15, 2) NOT NULL, 
	date_limite DATE, 
	entreprise_id INTEGER NOT NULL, 
	annee_scolaire_id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id), 
	FOREIGN KEY(annee_scolaire_id) REFERENCES annees_scolaires (id)
)
CREATE TABLE config_ecole (
	id INTEGER NOT NULL, 
	entreprise_id INTEGER NOT NULL, 
	annee_scolaire_en_cours_id INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id), 
	FOREIGN KEY(annee_scolaire_en_cours_id) REFERENCES annees_scolaires (id)
)
CREATE TABLE comptes_config (
	entreprise_id INTEGER NOT NULL, 
	compte_caisse_id INTEGER NOT NULL, 
	compte_frais_id INTEGER NOT NULL, 
	compte_client_id INTEGER NOT NULL, 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(compte_caisse_id) REFERENCES comptes_comptables (id), 
	FOREIGN KEY(compte_frais_id) REFERENCES comptes_comptables (id), 
	FOREIGN KEY(compte_client_id) REFERENCES comptes_comptables (id)
)
CREATE TABLE periodes_classes (
	id INTEGER NOT NULL, 
	classe_id INTEGER NOT NULL, 
	periode_id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(classe_id) REFERENCES classes (id), 
	FOREIGN KEY(periode_id) REFERENCES periodes (id)
)
CREATE TABLE eleves (
	id INTEGER NOT NULL, 
	nom VARCHAR(100) NOT NULL, 
	postnom VARCHAR(100), 
	prenom VARCHAR(100) NOT NULL, 
	sexe VARCHAR(10), 
	statut VARCHAR(30), 
	date_naissance DATE, 
	lieu_naissance VARCHAR(100), 
	matricule VARCHAR(50), 
	numero_permanent VARCHAR(50), 
	classe_id INTEGER, 
	responsable_id INTEGER, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(classe_id) REFERENCES classes (id), 
	FOREIGN KEY(responsable_id) REFERENCES responsables (id)
)
CREATE TABLE cours (
	id INTEGER NOT NULL, 
	code VARCHAR(5), 
	nom VARCHAR(100) NOT NULL, 
	coefficient INTEGER, 
	enseignant_id INTEGER NOT NULL, 
	classe_id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	UNIQUE (code), 
	FOREIGN KEY(enseignant_id) REFERENCES enseignants (id), 
	FOREIGN KEY(classe_id) REFERENCES classes (id)
)
CREATE TABLE frais_classes (
	id INTEGER NOT NULL, 
	frais_id INTEGER NOT NULL, 
	classe_id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(frais_id) REFERENCES frais_scolaires (id), 
	FOREIGN KEY(classe_id) REFERENCES classes (id)
)
CREATE TABLE notes_periode (
	id INTEGER NOT NULL, 
	eleve_id INTEGER NOT NULL, 
	cours_id INTEGER NOT NULL, 
	periode_id INTEGER NOT NULL, 
	valeur DECIMAL(5, 2), 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(eleve_id) REFERENCES eleves (id), 
	FOREIGN KEY(cours_id) REFERENCES cours (id), 
	FOREIGN KEY(periode_id) REFERENCES periodes (id)
)
CREATE TABLE paiement_frais (
	id INTEGER NOT NULL, 
	eleve_id INTEGER NOT NULL, 
	frais_scolaire_id INTEGER NOT NULL, 
	montant_paye DECIMAL(15, 2) NOT NULL, 
	date_paiement DATE NOT NULL, 
	user_id INTEGER, 
	reste_a_payer DECIMAL(15, 2), 
	statut VARCHAR(20), 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(eleve_id) REFERENCES eleves (id), 
	FOREIGN KEY(frais_scolaire_id) REFERENCES frais_scolaires (id), 
	FOREIGN KEY(user_id) REFERENCES utilisateurs (id)
)
CREATE TABLE creances (
	id INTEGER NOT NULL, 
	eleve_id INTEGER NOT NULL, 
	frais_scolaire_id INTEGER NOT NULL, 
	montant DECIMAL(15, 2) NOT NULL, 
	date_echeance DATE NOT NULL, 
	active BOOLEAN, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(eleve_id) REFERENCES eleves (id), 
	FOREIGN KEY(frais_scolaire_id) REFERENCES frais_scolaires (id)
)
CREATE TABLE journaux_comptables (
	date_operation DATETIME NOT NULL, 
	libelle VARCHAR(255) NOT NULL, 
	montant NUMERIC(15, 2) NOT NULL, 
	type_operation VARCHAR(20) NOT NULL, 
	paiement_frais_id INTEGER, 
	entreprise_id INTEGER NOT NULL, 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(paiement_frais_id) REFERENCES paiement_frais (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id)
)
CREATE TABLE depenses (
	libelle VARCHAR(255) NOT NULL, 
	montant NUMERIC(15, 2) NOT NULL, 
	date_depense DATETIME NOT NULL, 
	entreprise_id INTEGER NOT NULL, 
	observation TEXT, 
	journal_id INTEGER, 
	user_id INTEGER, 
	id INTEGER NOT NULL, 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(entreprise_id) REFERENCES entreprises (id), 
	FOREIGN KEY(journal_id) REFERENCES journaux_comptables (id), 
	FOREIGN KEY(user_id) REFERENCES utilisateurs (id)
)
CREATE TABLE ecritures_comptables (
	id INTEGER NOT NULL, 
	journal_id INTEGER NOT NULL, 
	compte_comptable_id INTEGER NOT NULL, 
	debit NUMERIC(15, 2), 
	credit NUMERIC(15, 2), 
	ordre INTEGER NOT NULL, 
	date_ecriture DATETIME NOT NULL, 
	libelle VARCHAR(255), 
	reference VARCHAR(100), 
	date_creation DATETIME NOT NULL, 
	date_modification DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(journal_id) REFERENCES journaux_comptables (id), 
	FOREIGN KEY(compte_comptable_id) REFERENCES comptes_comptables (id)
)
