# Delta

Fiches de révision de maths — Terminale spécialité, programme 2026‑2027.
Objectif : comprendre vite, réviser efficacement.

## Structure

Une fiche = un chapitre = un fichier HTML autonome (aucune dépendance, aucun build).
Chaque chapitre est découpé en parties, et chaque partie suit toujours le même plan :

| Onglet | Contenu |
|---|---|
| Cours | l'essentiel en quelques lignes, avec un schéma |
| Formules | ce qu'il faut savoir par cœur, visualisé |
| Exercices | 2 exercices-types courts, centrés sur la méthode, corrigés pas à pas |
| Astuces | astuces, pièges classiques et réflexes de rédaction du bac |

## Chapitres

- [x] `index.html` — **Suites numériques** (7 parties)

## Ouvrir

Ouvrir le fichier `.html` directement dans un navigateur.

## Partager une fiche

Les fiches sont écrites au format artifact (fragment HTML, sans `<head>`).
Pour obtenir un fichier autonome, envoyable à quelqu'un et ouvrable dans
n'importe quel navigateur sans compte ni connexion :

```sh
./build.sh index.html "dist/Delta - Suites numériques.html"
```

Le fichier produit est complet : styles, schémas et interactions inclus.
Seules les polices web sont téléchargées si le navigateur a accès à
internet ; sinon il bascule sur des polices système.

## Site en ligne

`docs/` contient le site publié par GitHub Pages. Il est **généré** — ne
pas l'éditer à la main. Après chaque modification d'une fiche :

```sh
./build.sh index.html docs/index.html
git add docs && git commit -m "Met à jour le site"
git push
```
