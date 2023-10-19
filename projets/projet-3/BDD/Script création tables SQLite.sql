PRAGMA foreign_keys=off;

CREATE TABLE region (
                code_region INT NOT NULL,
                nom_region VARCHAR(40) NOT NULL,
                PRIMARY KEY (code_region)
);


CREATE TABLE commune (
                id_commune VARCHAR(5) NOT NULL,
                code_region INT NOT NULL,
                code_departement VARCHAR(3) NOT NULL,
                nom_commune VARCHAR(50) NOT NULL,
                PRIMARY KEY (id_commune, code_region)
                FOREIGN KEY (code_region)
                REFERENCES region (code_region)
                ON DELETE NO ACTION
                ON UPDATE NO ACTION
);


CREATE TABLE population (
                id_commune VARCHAR(5) NOT NULL,
                code_region INT NOT NULL,
                population_municipale INT,
                population_comptee_a_part INT,
                PRIMARY KEY (id_commune, code_region)
                FOREIGN KEY (code_region, id_commune)
                REFERENCES commune (code_region, id_commune)
                ON DELETE NO ACTION
                ON UPDATE NO ACTION
);


CREATE TABLE bien (
                id_bien INT AUTO_INCREMENT NOT NULL,
                id_commune VARCHAR(5) NOT NULL,
                type_local VARCHAR(30) NOT NULL,
                surface_carrez DOUBLE PRECISIONS NOT NULL,
                surface_reelle INT NOT NULL,
                nombre_pieces INT NOT NULL,
                PRIMARY KEY (id_bien, id_commune)
                FOREIGN KEY (id_commune)
                REFERENCES commune (id_commune)
                ON DELETE NO ACTION
                ON UPDATE NO ACTION
);


CREATE TABLE vente (
                id_vente INT AUTO_INCREMENT NOT NULL,
                id_bien INT NOT NULL,
                date_vente DATE NOT NULL,
                valeur_vente INT,
                PRIMARY KEY (id_vente, id_bien)
                FOREIGN KEY (id_bien)
                REFERENCES bien (id_bien)
                ON DELETE NO ACTION
                ON UPDATE NO ACTION
);

PRAGMA foreign_keys=on;
