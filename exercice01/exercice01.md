# Exercice 1 : Cycle de vie d'un produit (CRUD)
## Objectif
Écrire un script PowerShell `exercice01.ps1` qui effectue un cycle de vie complet : création,
lecture, mise à jour, vérification et suppression. Le script doit produire un fichier de log comme
preuve de chaque étape.

## Exigences
1. Créer un nouveau produit avec les données JSON suivantes : Name = "Clavier AZERTY" , Category = "Electronique" , UnitPrice = 74.99 , Quantity = 200 , Supplier = "Logitech" .
2. Immédiatement après la création, récupérer le produit par son ID (depuis la réponse du POST) et vérifier que le nom correspond à ce que vous avez envoyé. Afficher un résultat PASS/FAIL.
3. Mettre à jour le produit : changer la quantité à 185 et le UnitPrice à 70.99 . Rappelezvous que l'API exige un corps de remplacement complet n'envoyez pas uniquement les champs modifiés.
4. Récupérer le produit à nouveau après la mise à jour et vérifier que la quantité et le UnitPrice ont bien changé. Afficher PASS/FAIL pour chaque champ.
5. Supprimer le produit par son ID.
6. Tenter de récupérer le produit supprimé et confirmer que vous recevez une réponse 404. Afficher PASS/FAIL.
7. Écrire toute la sortie (incluant les horodatages) dans un fichier de log nommé "exercice01.log" dans le répertoire courant. Chaque entrée de log doit inclure : l'horodatage au format ISO 8601, la méthode HTTP et l'URL appelée, le code de statut reçu, et tout résultat PASS/FAIL.

## Contraintes
- Vous devez utiliser Invoke-RestMethod ou Invoke-WebRequest . N'utilisez pas curl.exe ni aucun outil externe.
- Le script doit gérer les erreurs HTTP proprement. Si une étape échoue avec un code de statut inattendu, loguez l'erreur et continuez à l'étape suivante (n'utilisez pas -ErrorAction Stop globalement).
- Ne codez pas l'URL de base en dur. Acceptez comme paramètre : param([string]$BaseUrl) . Si le paramètre n'est pas fourni, utilisez par défaut http://localhost:5000/api/ .
- Le fichier de log doit être encodé en UTF-8