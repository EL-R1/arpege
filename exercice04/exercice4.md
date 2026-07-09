# Exercice 4 : Diagramme architecture & Plan d'implémentation
Fichiers à soumettre : `Exercice4` (PNG/PDF/SVG) + `Exercice4.txt`
Durée estimée : 25 minutes

## Scénario
Votre équipe gère une application legacy de gestion d'inventaire. Le codebase a 10 ans avec un backend, un frontend et une base de données PostgreSQL.
Un product manager vous demande d'implémenter la fonctionnalité suivante :
Demande de fonctionnalité : Import en masse de produits
Les utilisateurs doivent pouvoir uploader un fichier CSV contenant plusieurs produits via l'interface web. Le système doit valider chaque ligne, importer les produits valides, et montrer à l'utilisateur un résumé de ce qui a été importé et de ce qui a été rejeté (avec les raisons).
L'import doit également déclencher un email de notification de réapprovisionnement au fournisseur concerné si un produit importé a une quantité inférieure à 10.

## Ce que vous devez produire
### Partie A : Diagramme d'architecture

Dessinez un diagramme qui montre le flux de données complet pour cette fonctionnalité, depuis l'upload du CSV par l'utilisateur dans le navigateur jusqu'à l'envoi de l'email de notification.
Votre diagramme doit inclure :

- Le frontend : ce que l'utilisateur voit et avec quoi il interagit.
- La ou les requêtes HTTP entre frontend et backend : méthode, route, format de la payload.
- Le backend : le contrôleur, la couche service/logique métier et la couche d'accès aux données. Montrez où la validation se produit.
- La base de données : quelles tables sont lues ou écrites.
- La notification email : comment et quand elle est déclenchée (synchrone ? mise en file d'attente ? service séparé ?).
- La gestion des erreurs : où les erreurs peuvent se produire et comment elles remontent jusqu'à l'utilisateur.

### Partie B : Explication écrite (max 300 mots)
Dans un court document écrit, répondez aux questions suivantes :
1. Pourquoi avez-vous placé la validation du CSV là où vous l'avez placée (frontend, backend, ou les deux) ? Quels compromis avez-vous considérés ?
2. La notification email au fournisseur pourrait être faite de manière synchrone (dans la même requête HTTP) ou asynchrone (via une file d'attente ou un job en arrière-plan). Quelle approche avez-vous choisie et pourquoi ? Quels sont les risques de chaque approche ?
3. Supposons que le fichier CSV contienne 10 000 lignes. Comment votre design gérerait il cela sans que la requête HTTP n'expire ? Décrivez brièvement vous n'avez pas besoin de l'implémenter.
4. Un développeur propose d'ajouter la logique d'envoi d'email directement dans la méthode du contrôleur API. Que lui diriez-vous ?