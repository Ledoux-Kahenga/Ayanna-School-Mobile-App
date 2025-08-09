-- Table des entreprises (écoles)
CREATE TABLE entreprises (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    adresse TEXT,
    numero_id VARCHAR(100),
    devise VARCHAR(3),
    telephone VARCHAR(20),
    email VARCHAR(100),
    logo BLOB,
    date_creation DATETIME NOT NULL,
    date_modification DATETIME NOT NULL
);

-- Table de configuration générale de l'école
CREATE TABLE config_ecole (
    id INTEGER NOT NULL PRIMARY KEY,
    entreprise_id INTEGER NOT NULL,
    annee_scolaire_en_cours_id INTEGER,
    -- Relations : référence l'entreprise et l'année scolaire en cours
    FOREIGN KEY(entreprise_id) REFERENCES entreprises(id),
    FOREIGN KEY(annee_scolaire_en_cours_id) REFERENCES annees_scolaires(id)
);

-- Table des années scolaires
CREATE TABLE annees_scolaires (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    entreprise_id INTEGER NOT NULL,
    en_cours INTEGER DEFAULT 0,
    -- Relation : chaque année scolaire appartient à une entreprise
    FOREIGN KEY(entreprise_id) REFERENCES entreprises(id)
);


-- Table des classes
CREATE TABLE classes (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    annee_scolaire_id INTEGER NOT NULL,
    enseignant_id INTEGER,
    niveau VARCHAR(50),
    effectif INTEGER,
    code varchar(3),
    -- Relation : chaque classe appartient à une année scolaire et peut avoir un enseignant
    FOREIGN KEY(annee_scolaire_id) REFERENCES annees_scolaires(id),
    FOREIGN KEY(enseignant_id) REFERENCES enseignants(id)
);

-- Table des élèves
CREATE TABLE eleves (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    sexe VARCHAR(10),
    date_naissance DATE,
    lieu_naissance VARCHAR(100),
    numero_permanent VARCHAR(50),
    classe_id INTEGER,
    responsable_id INTEGER,
    matricule VARCHAR(50),
    postnom VARCHAR(100),
    statut VARCHAR(30) DEFAULT 'actif',
    -- Relations : chaque élève appartient à une classe et a un responsable
    FOREIGN KEY(classe_id) REFERENCES classes(id),
    FOREIGN KEY(responsable_id) REFERENCES "responsables_old"(id)
);

-- Table de liaison entre classes et frais scolaires (plus récente)
CREATE TABLE classe_frais (
    id INTEGER NOT NULL PRIMARY KEY,
    frais_id INTEGER NOT NULL,
    classe_id INTEGER NOT NULL,
    -- Relation : chaque enregistrement lie un frais scolaire à une classe
    FOREIGN KEY(frais_id) REFERENCES frais_scolaires(id),
    FOREIGN KEY(classe_id) REFERENCES classes(id)
);


-- Table des frais (ancienne version)
CREATE TABLE frais (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    montant INTEGER,
    entreprise_id INTEGER NOT NULL,
    code varchar(5),
    -- Relation : chaque frais appartient à une entreprise
    FOREIGN KEY(entreprise_id) REFERENCES entreprises(id)
);

-- Table de liaison entre frais scolaires et classes (plus récente)
CREATE TABLE frais_classes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    frais_id INTEGER NOT NULL,
    classe_id INTEGER NOT NULL,
    -- Relations : chaque enregistrement lie un frais scolaire à une classe
    FOREIGN KEY(frais_id) REFERENCES frais_scolaires(id),
    FOREIGN KEY(classe_id) REFERENCES classes(id)
);

-- Table des frais scolaires (plus complète)
CREATE TABLE frais_scolaires (
    id INTEGER NOT NULL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    montant DECIMAL(15, 2) NOT NULL,
    date_limite DATE,
    entreprise_id INTEGER NOT NULL,
    annee_scolaire_id INTEGER NOT NULL DEFAULT 1,
    code varchar(3),
    -- Relations : chaque frais scolaire appartient à une entreprise et une année scolaire
    FOREIGN KEY(entreprise_id) REFERENCES entreprises(id),
    FOREIGN KEY(annee_scolaire_id) REFERENCES annees_scolaires(id)
);

-- Table des paiements des frais scolaires
CREATE TABLE paiement_frais (
    id INTEGER NOT NULL PRIMARY KEY,
    eleve_id INTEGER NOT NULL,
    frais_scolaire_id INTEGER NOT NULL,
    montant_paye DECIMAL(15, 2) NOT NULL,
    date_paiement DATE NOT NULL,
    reste_a_payer DECIMAL(15, 2),
    statut VARCHAR(20),
    user_id INTEGER,
    -- Relations : chaque paiement est lié à un élève et à un frais scolaire
    FOREIGN KEY(eleve_id) REFERENCES eleves(id),
    FOREIGN KEY(frais_scolaire_id) REFERENCES frais_scolaires(id)
);