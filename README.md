# Cap Teranga

Application mobile de tourisme intelligente pour découvrir le Sénégal : sites historiques, lieux religieux, nature, plages, hôtels et restaurants, avec des recommandations personnalisées et un générateur d'itinéraire jour par jour.

Backend en **microservices Spring Boot** (Eureka, API Gateway, JWT, Feign, Resilience4j), front **Flutter**, base **MySQL**, observabilité **Prometheus / Grafana / Zipkin**, le tout orchestré avec **Docker Compose**.

## Fonctionnalités

- Inscription / connexion JWT avec rôles `USER` et `ADMIN`
- Catalogue : 25 sites touristiques, hôtels, restaurants et plages, avec coordonnées GPS
- Exploration en swipe (hôtels, plages, restaurants) et fiches détaillées
- Recherche unifiée avec filtres : type, catégorie, ville, note minimale (insensible aux accents)
- Carte interactive avec marqueurs par type et filtres
- Avis et notes, avec calcul automatique de la moyenne par lieu
- Favoris synchronisés avec le serveur et consultables hors connexion
- Réservation d'hôtel avec statuts `EN_ATTENTE → CONFIRMEE / ANNULEE`, annulation côté client, validation côté admin, notification à chaque changement
- Recommandations personnalisées (voir plus bas)
- Itinéraire personnalisé : nombre de jours + centres d'intérêt + ville de départ → circuit jour par jour avec hôtel et restaurant suggérés
- Espace admin : gestion des hôtels, restaurants, plages et réservations

## Architecture

```mermaid
flowchart LR
    App[App Flutter] --> GW[API Gateway :8080]
    GW --> AUTH[auth-service :8082]
    GW --> TOUR[tourism-service :8084]
    GW --> BOOK[booking-service :8086]
    GW --> RECO[recommendation-service :8087]
    GW --> NOTIF[notification-service :8083]
    GW --> USER[user-service :8085]
    BOOK -- Feign --> TOUR
    BOOK -- Feign --> AUTH
    BOOK -- Feign + Resilience4j --> NOTIF
    RECO -- Feign + Resilience4j --> TOUR
    RECO -- Feign + Resilience4j --> BOOK
    AUTH & TOUR & BOOK & RECO & NOTIF & USER --> DB[(MySQL)]
    EUREKA[discovery-server :8761] -.-> GW
```

| Service | Port | Rôle |
|---|---|---|
| discovery-server | 8761 | Annuaire Eureka |
| api-gateway | 8080 | Point d'entrée unique, routage `lb://` |
| auth-service | 8082 | Comptes, rôles, émission des JWT |
| notification-service | 8083 | Notifications utilisateur |
| tourism-service | 8084 | Lieux, hôtels, restaurants, plages, avis, recherche |
| user-service | 8085 | Profils utilisateurs |
| booking-service | 8086 | Réservations et statuts |
| recommendation-service | 8087 | Favoris, recommandations, itinéraires |

## Lancer le projet

### Backend

Prérequis : Docker et Docker Compose.

```bash
cd backend
docker compose up --build
```

Le premier build prend quelques minutes (téléchargement des dépendances Gradle). Au démarrage :

- les tables sont créées par Hibernate et le jeu de données du Sénégal est chargé automatiquement ;
- les rôles `USER` / `ADMIN` et un compte admin sont créés : `admin@discover.sn` / `admin123` (modifiable avec les variables `ADMIN_EMAIL` et `ADMIN_PASSWORD`).

Eureka : http://localhost:8761

### Application Flutter

```bash
cd frontend/tourisme_app
flutter pub get
flutter run --dart-define=API_URL=http://<ip-de-ta-machine>:8080
```

Sur l'émulateur Android, utiliser `http://10.0.2.2:8080`. Sans `API_URL`, l'application vise `http://192.168.1.105:8080`.

## Recommandations

Filtrage basé sur le contenu, calculé dans `recommendation-service` à partir du catalogue de `tourism-service`.

1. **Profil utilisateur** : chaque interaction ajoute un poids à la catégorie, à la ville et au type du lieu concerné : réservation (+4), favori (+3), like (+2), dislike (−1,5), catégories déclarées (+2).
2. **Score d'un lieu** : `0,45 × affinité catégorie + 0,20 × affinité ville + 0,10 × affinité type + 0,25 × note / 5`, chaque affinité étant normalisée par le maximum du profil.
3. Les lieux déjà réservés ou en favoris sont exclus, et chaque suggestion est accompagnée d'une explication (« Parce que vous aimez les lieux historiques »).
4. **Cold start** : sans historique, l'utilisateur reçoit les lieux les mieux notés, en alternant les types pour éviter une liste de 10 hôtels.

`GET /recommendations/user/{userId}?limit=10&categories=NATURE,HISTORIQUE`

## Itinéraire personnalisé

`GET /recommendations/itinerary?days=4&categories=NATURE,AVENTURE&start=Dakar`

- sélection des sites selon les centres d'intérêt, puis regroupement par ville ;
- choix de la ville suivante en équilibrant intérêt et distance : `intérêt / (1 + distance_km / 150)` (distance de Haversine) ;
- remplissage des journées jusqu'à 7 h de visite, en fusionnant les visites courtes de villes à moins de 70 km ;
- pour chaque jour, l'hôtel le plus proche (60 km max) et un restaurant à proximité (30 km max).

## Observabilité et résilience

Lancés avec le reste de la stack :

| Outil | URL | Usage |
|---|---|---|
| Grafana | http://localhost:3000 | Dashboard « Cap Teranga » : requêtes/s, latence p95, erreurs 5xx, état des circuit breakers, mémoire JVM, connexions DB |
| Prometheus | http://localhost:9090 | Collecte des métriques `/actuator/prometheus` de chaque service |
| Zipkin | http://localhost:9411 | Traces distribuées (Micrometer Tracing + Brave), propagées dans les appels Feign |

Resilience4j protège les appels inter-services :

- **recommendation → tourism** : circuit breaker ; si tourism-service tombe, le dernier catalogue reçu est servi depuis le cache ;
- **recommendation → booking** : circuit breaker + retry, repli sur une liste vide ;
- **booking → notification** : retry avec backoff exponentiel + circuit breaker ; une réservation n'échoue jamais à cause d'une notification.

## API principale

| Méthode | Route | Accès |
|---|---|---|
| POST | `/auth/register`, `/auth/login` | public |
| GET | `/hotels`, `/restaurants`, `/beaches`, `/places`, `/categories` | public |
| GET | `/search?q=&type=&city=&category=&minRating=&maxPrice=` | public |
| POST/PUT/DELETE | `/hotels`, `/restaurants`, `/beaches`, `/places` | ADMIN |
| GET / POST | `/reviews?entityId=&entityType=` | public |
| POST | `/reservations` | connecté |
| GET | `/reservations/user/{id}` | connecté |
| PUT | `/reservations/{id}/cancel` | connecté |
| GET, PUT | `/reservations`, `/reservations/{id}/confirm` | ADMIN |
| GET / POST / DELETE | `/recommendations/favorites` | connecté |
| GET | `/recommendations/user/{id}`, `/recommendations/itinerary` | connecté |

## Données

Le jeu de données (`tourism-service/src/main/resources/data.sql`) couvre Dakar, Saint-Louis, la Petite-Côte, le Sine-Saloum, Touba, Tivaouane, Kaolack, la Casamance et le Sénégal oriental. Les coordonnées GPS sont approximatives et les prix des hôtels sont indicatifs.

## Crédits photos

Photos issues de Wikimedia Commons, sous licence libre. Les auteurs et licences exactes sont indiqués sur chaque page :

- Île de Gorée — [Ile-de-goree.jpg](https://commons.wikimedia.org/wiki/File:Ile-de-goree.jpg)
- Monument de la Renaissance africaine — [Monument_renaissance.jpg](https://commons.wikimedia.org/wiki/File:Monument_renaissance.jpg)
- Lac Rose — [Lac_Rose_in_Senegal.jpg](https://commons.wikimedia.org/wiki/File:Lac_Rose_in_Senegal.jpg)
- Grande Mosquée de Touba — [Touba_moschee.jpg](https://commons.wikimedia.org/wiki/File:Touba_moschee.jpg)
- Île de Saint-Louis — [Island_of_Saint-Louis-113799.jpg](https://commons.wikimedia.org/wiki/File:Island_of_Saint-Louis-113799.jpg)
- Pont Faidherbe — [Saintlouis_pont_Faidherbe.jpg](https://commons.wikimedia.org/wiki/File:Saintlouis_pont_Faidherbe.jpg)

- Maison des esclaves — [Maison des Esclaves 04045.JPG](https://commons.wikimedia.org/wiki/File:Maison_des_Esclaves_04045.JPG), Serge Ottaviani
- Musée des Civilisations noires — [Musée des civilisations noires 2022.jpg](https://commons.wikimedia.org/wiki/File:Mus%C3%A9e_des_civilisations_noires_2022.jpg), PMO Barbados, domaine public
- Musée Théodore Monod — [Musée d'art africain Théodore Monod.jpg](https://commons.wikimedia.org/wiki/File:Mus%C3%A9e_d'art_africain_Th%C3%A9odore_Monod.jpg), Zythème
- Mosquée de la Divinité — [Ouakam-Mosquée de la Divinité (3).jpg](https://commons.wikimedia.org/wiki/File:Ouakam-Mosqu%C3%A9e_de_la_Divinit%C3%A9_(3).jpg), Jeff Attaway, CC BY 2.0
- Phare des Mamelles — [PhareMamelles4.JPG](https://commons.wikimedia.org/wiki/File:PhareMamelles4.JPG), Ji-Elle
- Grande Mosquée de Tivaouane — [La mosquée de serigne Babacar sy.jpg](https://commons.wikimedia.org/wiki/File:La_mosqu%C3%A9e_de_serigne_Babacar_sy.jpg), Sallboss
- Médina Baye — [MedinaBaayMosque.jpg](https://commons.wikimedia.org/wiki/File:MedinaBaayMosque.jpg), Joseph Hill, CC BY-SA 2.5
- Basilique de Popenguine — [PopenguineChurch.JPG](https://commons.wikimedia.org/wiki/File:PopenguineChurch.JPG), Ji-Elle
- Parc du Djoudj — [Pélicans au Parc national du Djoudj.jpg](https://commons.wikimedia.org/wiki/File:P%C3%A9licans_au_Parc_national_du_Djoudj.jpg), Ji-Elle
- Langue de Barbarie — [Le nouveau embouchure de Saint-Louis situant au Parc National de la Langue de Barbarie (PNLB) 05.jpg](https://commons.wikimedia.org/wiki/File:Le_nouveau_embouchure_de_Saint-Louis_situant_au_Parc_National_de_la_Langue_de_Barbarie_(PNLB)_05.jpg), 6artphotographie
- Delta du Saloum — [Mangrove île du Saloum Sénégal.jpg](https://commons.wikimedia.org/wiki/File:Mangrove_%C3%AEle_du_Saloum_S%C3%A9n%C3%A9gal.jpg), Ourytima, CC BY-SA 4.0
- Réserve de Bandia — [Girafe dans la réserve de Bandia Sénégal 01.jpg](https://commons.wikimedia.org/wiki/File:Girafe_dans_la_r%C3%A9serve_de_Bandia_S%C3%A9n%C3%A9gal_01.jpg), Josi Salgado, CC BY-SA 4.0
- Désert de Lompoul — [2017-06 Lompoul Desert 2.jpg](https://commons.wikimedia.org/wiki/File:2017-06_Lompoul_Desert_2.jpg), Mich-nguyen, CC BY-SA 4.0
- Île de Fadiouth — [Pont de l’Aire Marine Protégée de Joal-Fadiouth 18.jpg](https://commons.wikimedia.org/wiki/File:Pont_de_l%E2%80%99Aire_Marine_Prot%C3%A9g%C3%A9e_de_Joal-Fadiouth_18.jpg), Wuzyprod
- Île de Carabane — [Carabane-Bolongs.JPG](https://commons.wikimedia.org/wiki/File:Carabane-Bolongs.JPG), Ji-Elle
- Parc du Niokolo-Koba — [Paysage du parc Niokolo Koba du Sénégal.jpg](https://commons.wikimedia.org/wiki/File:Paysage_du_parc_Niokolo_Koba_du_S%C3%A9n%C3%A9gal.jpg), COD photographer
- Cascade de Dindéfélo — [Cascade de Dindefelo 02.jpg](https://commons.wikimedia.org/wiki/File:Cascade_de_Dindefelo_02.jpg), Mouha.ibs, CC BY-SA 4.0
- Plage de Cap Skirring — [Cap-Skirring-Beach-2007.jpg](https://commons.wikimedia.org/wiki/File:Cap-Skirring-Beach-2007.jpg), Bjørn Christian Tørrissen, CC BY-SA 3.0
- Plage de la Somone — [Lagune de LA SOMONE.jpg](https://commons.wikimedia.org/wiki/File:Lagune_de_LA_SOMONE.jpg), Faisans.jeanluc, CC BY-SA 3.0
- Plage de Popenguine — [Plage réserve naturelle de Popenguine, Thies Sénégal, Juin 2022.jpg](https://commons.wikimedia.org/wiki/File:Plage_r%C3%A9serve_naturelle_de_Popenguine,_Thies_S%C3%A9n%C3%A9gal,_Juin_2022.jpg), Ousmane Goudiaby 95
- Plage de Toubab Dialaw — [Toubab Dialaw 294A2254 Senegal.jpg](https://commons.wikimedia.org/wiki/File:Toubab_Dialaw_294A2254_Senegal.jpg), Christian Pirkl

Les hôtels, les restaurants, la plage des Almadies, le village de Soumbédioune et le marché Kermel affichent un visuel de remplacement : pas de photo libre fiable trouvée pour eux.

## Pistes d'évolution

- Upload des photos vers Cloudinary
- Paiement mobile Wave / Orange Money
- Interface en wolof, français et anglais
- Déploiement Kubernetes (Minikube) avec probes `liveness` / `readiness`, déjà exposées par Actuator

## Auteure

Ndeye Maguette Kane — Master 2 Systèmes d'Information Répartis, FST-UCAD
