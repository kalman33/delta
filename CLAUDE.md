# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Delta — fiches de révision de maths, Terminale spécialité 2026‑2027. Contenu et
interface en français ; écrire le contenu, les commits et les libellés en français.

## Commandes

Pas de `package.json`, pas de dépendances, pas de build, pas de tests.

```sh
# Emballer une fiche en fichier autonome (à envoyer à quelqu'un)
./build.sh index.html "dist/Delta - Suites numériques.html"

# Régénérer le site GitHub Pages — à refaire après CHAQUE modification d'une fiche
./build.sh index.html docs/index.html

# Contrôler la syntaxe du <script> (le seul « test » disponible)
python3 -c "s=open('index.html').read(); open('/tmp/d.js','w').write(s.split('<script>')[1].split('</script>')[0])" && node --check /tmp/d.js
```

`docs/` est **généré** : ne jamais l'éditer à la main, toujours le régénérer puis le
commiter. `dist/` est ignoré par git.

## Trois cibles de publication

Une même source, `index.html`, part vers trois endroits qui doivent rester alignés :

1. **Artifact** — `Artifact` sur `index.html` (même chemin ⇒ même URL,
   https://claude.ai/artifact/3ox47HHfZfX3fn3CVRqvtF). C'est la cible de référence.
2. **GitHub Pages** — `docs/index.html`, via `build.sh`, publié sur
   https://kalman33.github.io/delta/ (dépôt `kalman33/delta`).
3. **Fichier autonome** — `dist/`, via `build.sh`, pour un envoi hors ligne.

Un changement de fiche n'est terminé qu'une fois les trois à jour : publier
l'artifact, régénérer `docs/`, commiter.

## Format du fichier source

`index.html` est un **fragment au format artifact** : il commence directement par
`<title>`, sans `<!doctype>`, `<html>`, `<head>` ni `<body>` — la plateforme les
ajoute à la publication. `build.sh` fait la même chose pour les autres cibles.
Ne pas « réparer » cette absence.

Conséquence des règles CSP des artifacts : **aucune ressource externe** n'est
chargeable, hormis la feuille de style Google Fonts. C'est la raison pour laquelle
le rendu mathématique est écrit à la main plutôt que délégué à KaTeX (dont le CSS
et les polices seraient bloqués). Ne pas proposer d'ajouter une bibliothèque.

## Architecture de `index.html`

Ordre du fichier : `<title>` → fonts → `<style>` (tokens puis composants) →
`<header>` → `.shell` (sommaire + `<main>`) → sections → `<footer>` → `<script>`
(IIFE unique, `"use strict"`).

### Moteur mathématique — le point le plus piégeux

`renderMath()` sélectionne tout élément portant la classe `.m`, lit son
`textContent` et **réécrit son `innerHTML`**. Notation reconnue par `parse()` :

| Notation | Rendu |
|---|---|
| `u_n`, `u_{n+1}` | indice |
| `q^n`, `q^{n+1}` | exposant |
| `@{num}{den}` | fraction (imbrication autorisée) |
| lettre isolée | mise en italique automatique |

Trois règles qui en découlent :

- **`.m` est réservé au moteur.** Ne jamais s'en servir comme nom de classe pour
  autre chose : le moteur détruirait le balisage interne de l'élément. Un bug réel
  a déjà été causé par des boutons nommés `nd m` (numéro de partie avalé, lettres
  isolées italisées, troncature). Les libellés de boutons portent `.lbl`.
- Dans un `.m`, écrire en notation, pas en HTML. Hors d'un `.m` (libellés,
  en-têtes), écrire du HTML ordinaire avec `<sub>` / `<sup>`.
- `<` et `>` dans un `.m` s'écrivent `&lt;` / `&gt;` dans la source.

Les fractions sont calées par `vertical-align: middle` sur `.frac` : le centre de
la boîte, donc la barre, tombe sur l'axe mathématique du texte. Ne pas repasser à
un décalage en `em` — la ligne de base d'une boîte `inline-flex` en colonne est
celle du numérateur, ce qui fait plonger toute la fraction.

### Contrat de balisage d'une section

```html
<section class="part" id="p8" data-num="08" data-title="Titre court">
  <div class="phead">
    <div class="num">08</div>
    <div><h2>…</h2><div class="sub">…</div></div>
    <label class="rev"><input type="checkbox" data-rev="p8"><span>Révisé</span></label>
  </div>
  <div class="pane" data-tab="Cours">…</div>
  <div class="pane" data-tab="Formules">…</div>
</section>
```

Tout le reste est dérivé du DOM au chargement : `buildTabs()` fabrique la barre
d'onglets à partir des `.pane[data-tab]` (et ne fait rien s'il y en a moins de
deux — c'est ainsi que l'arbre et les exercices mixtes restent sans onglets) ;
le sommaire, la barre de progression et le scroll-spy se construisent à partir
des `section.part`. **Ajouter une partie = ajouter du balisage, sans toucher au
JS.** Seules les sections portant un `[data-rev]` comptent dans la progression.

`init()` enveloppe ensuite les onglets et les volets dans
`.pfold > .pbody` et ajoute le chevron : c'est l'accordéon. Ne pas écrire ces
éléments dans le balisage, ils sont créés au chargement. Cocher « Révisé » replie
la partie ; le pli reste réglable à la main et se mémorise dans `delta.fold`,
donc une partie révisée puis rouverte reste ouverte.

### Blocs pilotés par des données

- `VIZ` — un schéma par `<div class="viz" data-viz="…">`. Les courbes sont tracées
  par `chart()` à partir des valeurs réellement calculées (`seqRec`, `seqExp`),
  jamais de points inventés.
- `TREE` / `RFLX` — l'arbre de décision. Voir le README pour la règle d'écriture :
  **une branche doit se reconnaître à l'œil sur l'énoncé**, jamais exiger un calcul
  préalable. Ce qui ne branche pas va dans `RFLX`.
- `explorer()` — l'explorateur interactif de la partie 02.

### Thème et couleurs

Trois états : `data-theme="light"`, `data-theme="dark"`, et rien du tout (réglage
système). Tout jeton est déclaré sur `:root` nu, puis redéfini dans
`@media (prefers-color-scheme: dark)` gardé par `:root:not([data-theme="light"])`,
puis dans `:root[data-theme="dark"]`. **Ne jamais donner à une couleur son unique
définition dans un de ces blocs** : elle ne s'appliquerait pas en mode système.

`--conv` (vert) et `--div` (orange) sont **sémantiques** : convergence et
divergence. Elles servent aux courbes, aux pastilles et aux pièges — pas de
décoration.

### État persistant

`localStorage`, via `LS.get` / `LS.set` (try/catch obligatoire) : `delta.done`
(parties révisées), `delta.fold` (parties repliées), `delta.tab.<id>`, `delta.nav`,
`delta.theme`. La page doit
rester correcte si tout revient vide.

## Vérifier un rendu

Il n'y a pas de tests : un bug visuel se constate à l'écran. Recette utilisée pour
isoler une section et la capturer.

```sh
python3 - <<'PY'
s=open('docs/index.html').read()
s=s.replace('</head>','<style>section.part:not(#pq){display:none!important}'
            '.hero,nav.side,footer{display:none!important}</style></head>',1)
open('/tmp/iso.html','w').write(s)
PY
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu \
  --window-size=1000,1500 --hide-scrollbars --virtual-time-budget=5000 \
  --screenshot=/tmp/shot.png "file:///tmp/iso.html"
```

Variantes utiles : `.pane[hidden]{display:block!important}` pour voir tous les
onglets d'un coup, `<details class="fix" open>` pour déplier les corrigés.

**Chrome headless impose une fenêtre minimale de 500 px de large** : demander 430
produit une capture rognée qui simule un faux débordement horizontal. Pour
diagnostiquer un vrai débordement, comparer `document.documentElement.scrollWidth`
à `clientWidth` depuis un script injecté, plutôt que de se fier à l'image.

## Conventions de contenu

- Un **fil rouge** par chapitre : la même suite (`u₀ = 2`, `uₙ₊₁ = 0,5uₙ + 3`)
  traverse les parties 01, 03, 06 et 07 pour montrer l'enchaînement des questions
  d'un sujet de bac. Réutiliser ce principe dans les nouveaux chapitres.
- Les exercices visent **la méthode**, pas la longueur : 4 à 5 étapes numérotées,
  corrigé masqué derrière `<details class="fix">`.
- Onglet Formules : une phrase de cadrage (`.ftop`), puis une carte
  `.fbox.key` avec l'essentiel, puis le détail.
- Astuces classées en trois familles : `piege`, `astuce`, `bac`.

## Import d'une configuration tierce

Une configuration Gemini CLI existe sur cette machine (`~/.gemini/settings.json`).
Pour l'importer (serveurs MCP, commandes, sous-agents, skills, instructions),
répondre `/import` pour obtenir la liste de ce qui est importable, puis
`/import --yes=<digest>`. Si `/import` n'est pas disponible ici, lancer
`claude import` depuis un terminal.
