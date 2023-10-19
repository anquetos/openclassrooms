-- 1. Nombre total d’appartements vendus au 1er semestre 2020

SELECT COUNT(b.id_bien) AS nombre_appartements_vendus_S1_2020
  FROM bien b
       JOIN
       vente v ON b.id_bien = v.id_bien
 WHERE b.type_local = 'Appartement' AND 
       v.date_vente BETWEEN '2020-01-01' AND '2020-06-30';

       
-- 2. Le nombre de ventes d’appartement par région pour le 1er semestre 2020

SELECT r.nom_region AS region,
       COUNT(v.id_vente) AS nombre_ventes_appartements_S1_2020
  FROM vente v
       JOIN
       bien b ON b.id_bien = v.id_bien
       JOIN
       commune c ON c.id_commune = b.id_commune
       JOIN
       region r ON r.code_region = c.code_region
 WHERE b.type_local = 'Appartement' AND 
       v.date_vente BETWEEN '2020-01-01' AND [2020-06-30]
 GROUP BY region
 ORDER BY nombre_ventes_appartements_S1_2020 DESC;



-- 3. Proportion des ventes d’appartements par le nombre de pièces

SELECT b.nombre_pieces AS nombre_de_pieces,
       FORMAT('%2.2f%%', CAST (COUNT(v.id_vente) AS FLOAT) / SUM(COUNT(v.id_vente) ) OVER () * 100) AS proportion_ventes_appartements
  FROM vente v
       JOIN
       bien b ON b.id_bien = v.id_bien
 WHERE b.type_local = 'Appartement'
 GROUP BY nombre_de_pieces
 ORDER BY nombre_de_pieces;


-- 4. Liste des 10 départements où le prix du mètre carré est le plus élevé

SELECT c.code_departement AS departement,
       ROUND(AVG( (CAST (v.valeur_vente AS FLOAT) / b.surface_reelle) ), 0) AS prix_au_m2_reel
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
 WHERE v.valeur_vente <> ''
 GROUP BY departement
 ORDER BY prix_au_m2_reel DESC
 LIMIT 10;

 
-- 5. Prix moyen du mètre carré d’une maison en Île-de-France

SELECT r.nom_region AS region,
       ROUND(AVG( (CAST (v.valeur_vente AS FLOAT) / b.surface_reelle) ), 0) AS prix_au_m2_reel
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
       JOIN
       region r ON c.code_region = r.code_region
 WHERE b.type_local = 'Maison' AND 
       r.nom_region LIKE LOWER('%le%de%france') AND 
       v.valeur_vente <> '';

 
-- 6. Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés

SELECT v.id_bien AS id_bien,
       v.valeur_vente AS valeur_vente,
       r.nom_region AS region,
       b.surface_reelle AS surface_reelle_en_m2
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
       JOIN
       region r ON c.code_region = r.code_region
 WHERE b.type_local = 'Appartement' AND 
       v.valeur_vente <> ''
 ORDER BY valeur_vente DESC
 LIMIT 10;


-- 7. Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020

WITH ventes_t1_2020 AS (
    SELECT COUNT(v.id_vente) AS nb_ventes_t1_2020
      FROM vente v
     WHERE v.date_vente BETWEEN '2020-01-01' AND '2020-03-31'
),
ventes_t2_2020 AS (
    SELECT COUNT(v.id_vente) AS nb_ventes_t2_2020
      FROM vente v
     WHERE v.date_vente BETWEEN '2020-04-01' AND '2020-06-30'
)
SELECT ventes_t1_2020.nb_ventes_t1_2020 AS nombre_ventes_T1_2020,
       ventes_t2_2020.nb_ventes_t2_2020 AS nombre_ventes_T2_2020,
       FORMAT('%.1f%%', CAST ( (ventes_t2_2020.nb_ventes_t2_2020 - ventes_t1_2020.nb_ventes_t1_2020) AS FLOAT) / ventes_t1_2020.nb_ventes_t1_2020 * 100) AS evolution_T2_vs_T1
  FROM ventes_t1_2020,
       ventes_t2_2020;


-- 8. Le classement des régions par rapport au prix au mètre carré des appartement de plus de 4 pièces

SELECT r.nom_region AS region,
       ROUND(AVG(v.valeur_vente / b.surface_reelle), 0) AS prix_au_m2_reel
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
       JOIN
       region r ON c.code_region = r.code_region
 WHERE b.type_local = 'Appartement' AND 
       b.nombre_pieces > 4 AND 
       v.valeur_vente <> ''
 GROUP BY region
 ORDER BY prix_au_m2_reel DESC;


-- 9. Liste des communes ayant eu au moins 50 ventes au 1er trimestre

SELECT c.nom_commune AS commune,
       COUNT(v.id_vente) AS nombre_de_ventes_T1
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
 WHERE v.date_vente BETWEEN '2020-01-01' AND '2020-03-31'
 GROUP BY commune
HAVING nombre_de_ventes_T1 >= 50
 ORDER BY nombre_de_ventes_T1 DESC;


-- 10. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces

WITH appart_2_pieces AS (
    SELECT ROUND(AVG(v.valeur_vente / b.surface_reelle), 0) AS prix_m2_2P
      FROM vente v
           JOIN
           bien b ON v.id_bien = b.id_bien
     WHERE b.type_local = 'Appartement' AND 
           v.valeur_vente <> '' AND 
           b.nombre_pieces = 2
),
appart_3_pieces AS (
    SELECT ROUND(AVG(v.valeur_vente / b.surface_reelle), 0) AS prix_m2_3P
      FROM vente v
           JOIN
           bien b ON v.id_bien = b.id_bien
     WHERE b.type_local = 'Appartement' AND 
           v.valeur_vente <> '' AND 
           b.nombre_pieces = 3
)
SELECT appart_2_pieces.prix_m2_2P AS prix_m2_reel_appartements_2_pieces,
       appart_3_pieces.prix_m2_3P AS prix_m2_reel_appartements_3_pieces,
       FORMAT('%.1f%', (appart_2_pieces.prix_m2_2P - appart_3_pieces.prix_m2_3P) / appart_2_pieces.prix_m2_2P * 100) AS difference_2_pieces_vs_3_pieces
  FROM appart_2_pieces,
       appart_3_pieces;


-- 11. Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69

SELECT c.nom_commune AS commune,
       ROUND(AVG(v.valeur_vente), 0) AS moyenne_valeur_fonciere
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
 WHERE c.code_departement IN ('06', '13', '33', '59', '69') AND 
       v.valeur_vente <> ''
 GROUP BY commune
 ORDER BY moyenne_valeur_fonciere DESC
 LIMIT 3;


-- 12. Les 20 communes avec le plus de transactions pour 1000 habitants pour les communes qui dépassent les 10 000 habitants

SELECT c.nom_commune AS commune,
       FORMAT('%.2f', CAST (COUNT(v.id_vente) AS FLOAT) * 1000 / (p.population_municipale + p.population_comptee_a_part) ) AS transactions_pour_1000_habitants
  FROM vente v
       JOIN
       bien b ON v.id_bien = b.id_bien
       JOIN
       commune c ON b.id_commune = c.id_commune
       JOIN
       population p ON c.id_commune = p.id_commune
 WHERE (p.population_municipale + p.population_comptee_a_part) > 10000
 GROUP BY commune
 ORDER BY transactions_pour_1000_habitants DESC
 LIMIT 20;
