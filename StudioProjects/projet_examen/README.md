# 🌤️ MétéoVision

Application Flutter de météo en temps réel pour 5 villes mondiales avec carte interactive.

## 🚀 Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.7.0
- [Android Studio](https://developer.android.com/studio) avec le plugin Flutter installé
- Un compte [OpenWeatherMap](https://openweathermap.org/api) pour obtenir une clé API gratuite

## ⚙️ Installation

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd projet_examen
```

### 2. Installer les dépendances

```bash
flutter pub get
```

> Flutter génère automatiquement le fichier `android/local.properties` avec tes chemins SDK lors du premier `flutter pub get` ou `flutter run`. **Tu n'as pas besoin de le créer manuellement.**

### 3. Configurer la clé API

Copier le fichier d'exemple et renseigner ta clé :

```bash
cp .env.example .env
```

Ouvrir `.env` et remplacer `REMPLACER_PAR_VOTRE_CLE_API` par ta vraie clé OpenWeatherMap.

### 4. Lancer l'application

**Méthode recommandée (avec la clé API) :**

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=ta_cle_api_ici
```

**Via Android Studio :**

1. Ouvrir `Run > Edit Configurations`
2. Dans le champ **Additional run args**, ajouter :
   ```
   --dart-define=OPENWEATHER_API_KEY=ta_cle_api_ici
   ```
3. Cliquer sur **Run** ▶️

## 📁 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   ├── app_config.dart          # Configuration (clé API)
│   ├── config.dart              # Constantes globales
│   └── ville.dart               # Modèle Ville
├── services/
│   └── weather_service.dart     # Appels API OpenWeatherMap
├── theme/
│   └── theme_manager.dart       # Gestion thème clair/sombre
├── screens/
│   ├── home_screen.dart         # Écran d'accueil
│   ├── second_screen.dart       # Écran principal
│   └── ville_details_screen.dart # Détails + Carte
└── widgets/
    ├── waiting_message.dart     # Chargement & résultats
    └── meteo_table.dart         # Tableau des villes
```

## 🎨 Fonctionnalités

- ✅ Météo en temps réel via OpenWeatherMap
- ✅ 5 villes : Dakar, Paris, Tokyo, New York, London
- ✅ Carte interactive OpenStreetMap / CartoDB Dark
- ✅ Mode sombre / clair avec toggle
- ✅ Animations Lottie
- ✅ Gestion des erreurs réseau
