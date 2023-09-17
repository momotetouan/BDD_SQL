--R1--

SELECT * FROM Personne WHERE numPers IN (
SELECT numPersPere FROM PereDe GROUP BY numPersPere HAVING COUNT(*)>=2
UNION
SELECT numPersMere FROM MereDe GROUP BY numPersMere HAVING COUNT(*)>=2
);



--R2--

SELECT * FROM Personne WHERE numPers IN(
SELECT MDe.numPersMere FROM MereDe MDe JOIN PereDe PDe ON MDe.numPersEnfant=PDe.numPersPere
UNION
SELECT MDe.numPersMere FROM MereDe MDe JOIN MereDe MDe2 ON MDe.numPersEnfant=MDe2.numPersMere
);

SELECT * FROM Personne WHERE numPers IN(
SELECT PDe.numPersPere FROM PereDe PDe JOIN MereDe MDe ON PDe.numPersEnfant=MDe.numPersMere
UNION
SELECT PDe.numPersPere FROM PereDe PDe JOIN PereDe PDe2 ON PDe.numPersEnfant=PDe2.numPersPere
);



--R3--

SELECT * FROM Personne WHERE numPers IN(
    SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Paul')
);



--R4--

SELECT * FROM Personne WHERE numPers IN(
    SELECT numPersEnfant FROM MereDe WHERE numPersMere=(
        SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
            SELECT numPers FROM Personne WHERE nomPers='Dupont' AND prenomPers='Jeanne'))
        MINUS (SELECT numPers FROM Personne WHERE nomPers='Dupont' AND prenomPers='Jeanne')
);



--R5--

CREATE OR REPLACE VIEW nbEnfant(numPersMere,nb) AS
SELECT numPersMere,COUNT(*) FROM MereDe GROUP BY numPersMere;


SELECT * FROM Personne WHERE numPers IN(
    SELECT numPersMere FROM nbEnfant WHERE nb=(SELECT MAX(nb) FROM nbEnfant)
);



--R6--

SELECT * FROM Personne WHERE numPers NOT IN(
    SELECT numPersPere FROM PereDe
    UNION
    SELECT numPersMere FROM MereDe
);



--R7--

CREATE OR REPLACE VIEW couple(numPersPere,numPersMere) AS
SELECT DISTINCT numPersPere,numPersMere FROM PereDe NATURAL JOIN MereDe;


SELECT * FROM Personne WHERE numPers IN(
    SELECT numPersMere FROM couple GROUP BY numPersMere HAVING COUNT(*)=1
    UNION
    SELECT numPersPere FROM couple GROUP BY numPersPere HAVING COUNT(*)=1
);



--R8--

SELECT * FROM Personne WHERE numPers NOT IN(
    SELECT numPersEnfant FROM PereDe
    UNION
    SELECT numPersEnfant FROM MereDe
);



--R9--

SELECT * FROM Personne WHERE numPers NOT IN(
    SELECT numPersEnfant FROM PereDe
    INTERSECT
    SELECT numPersEnfant FROM MereDe
);



--R10--

SELECT * FROM Personne WHERE numPers IN (
    SELECT numPersEnfant FROM PereDe WHERE numPersPere IN (
        SELECT numPersPere FROM PereDe GROUP BY numPersPere HAVING COUNT(*)=1)
    UNION
    SELECT numPersEnfant FROM MereDe WHERE numPersMere IN (
        SELECT numPersMere FROM MereDe GROUP BY numPersMere HAVING COUNT(*)=1)
);



--R11--

CREATE OR REPLACE VIEW GrandPereP(numPers) AS
SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
    SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc'));


CREATE OR REPLACE VIEW GrandMereP(numPers) AS
SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
    SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc'));


CREATE OR REPLACE VIEW GrandPereM(numPers) AS
SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
    SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc'));


CREATE OR REPLACE VIEW GrandMereM(numPers) AS
SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
    SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc'));


CREATE OR REPLACE VIEW Parent(numPers) AS
SELECT numPersPere FROM PereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc')
UNION
SELECT numPersMere FROM MereDe WHERE numPersEnfant=(
        SELECT numPers FROM Personne WHERE nomPers='Durand' AND prenomPers='Luc');


CREATE OR REPLACE VIEW OncleTante(numPers) AS
SELECT m.numPersEnfant FROM MereDe m JOIN GrandMereP g ON m.numPersMere=g.numPers
UNION
SELECT p.numPersEnfant FROM PereDe p JOIN GrandPereP g ON p.numPersPere=g.numPers
UNION
SELECT m.numPersEnfant FROM MereDe m JOIN GrandMereM g ON m.numPersMere=g.numPers
UNION
SELECT p.numPersEnfant FROM PereDe p JOIN GrandPereM g ON p.numPersPere=g.numPers;


SELECT nomPers,PrenomPers,numPersEnfant FROM OncleTante 
    JOIN MereDe m ON OncleTante.numPers = m.numPersMere
        JOIN Personne ON Personne.numPers = m.numPersEnfant
UNION
SELECT nomPers,PrenomPers,numPersEnfant FROM OncleTante 
    JOIN PereDe p ON OncleTante.numPers = p.numPersPere
        JOIN Personne ON Personne.numPers = p.numPersEnfant;