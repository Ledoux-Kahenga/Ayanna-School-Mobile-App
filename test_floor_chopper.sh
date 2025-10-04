#!/bin/bash

echo "=== Test d'intégration Floor & Chopper ==="
echo ""

# Vérifier les dépendances
echo "1. Vérification des dépendances..."
if ! flutter pub get; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi
echo "✅ Dépendances installées"
echo ""

# Générer le code
echo "2. Génération du code..."
if ! dart run build_runner build --delete-conflicting-outputs; then
    echo "❌ Erreur lors de la génération du code"
    exit 1
fi
echo "✅ Code généré avec succès"
echo ""

# Vérifier les fichiers générés
echo "3. Vérification des fichiers générés..."

FILES_TO_CHECK=(
    "lib/models/entities/entreprise.g.dart"
    "lib/models/entities/utilisateur.g.dart"
    "lib/models/app_database.g.dart"
    "lib/services/api/entreprise_service.chopper.dart"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file manquant"
    fi
done
echo ""

# Analyse du code
echo "4. Analyse du code..."
if ! flutter analyze; then
    echo "⚠️  Des warnings d'analyse ont été détectés"
else
    echo "✅ Analyse du code réussie"
fi
echo ""

# Test de compilation
echo "5. Test de compilation..."
if ! flutter build apk --debug --no-sound-null-safety; then
    echo "❌ Erreur de compilation"
    exit 1
fi
echo "✅ Compilation réussie"
echo ""

echo "=== Test terminé avec succès ! ==="
echo ""
echo "Pour utiliser Floor & Chopper dans votre projet :"
echo "1. Copiez les entités depuis lib/models/entities/"
echo "2. Configurez l'URL API dans lib/services/api/api_client.dart"
echo "3. Utilisez EntrepriseService comme exemple pour vos autres entités"
echo "4. Consultez FLOOR_CHOPPER_GUIDE.md pour plus de détails"
