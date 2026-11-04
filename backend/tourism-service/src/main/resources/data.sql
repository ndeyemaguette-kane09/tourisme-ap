-- Coordonnées GPS approximatives, prix des hôtels indicatifs (FCFA / nuit).

INSERT IGNORE INTO category (id, name, description) VALUES
(1, 'CULTUREL', 'Sites culturels et traditions du Sénégal'),
(2, 'RELIGIEUX', 'Lieux religieux et spirituels'),
(3, 'GASTRONOMIQUE', 'Restaurants et expériences culinaires'),
(4, 'BALNEAIRE', 'Plages et détente au bord de la mer'),
(5, 'NATURE', 'Parcs, réserves naturelles et écotourisme'),
(6, 'HISTORIQUE', 'Sites historiques et monuments'),
(7, 'AVENTURE', 'Activités aventureuses et excursions'),
(8, 'MODERNE', 'Lieux modernes et urbains');

INSERT IGNORE INTO city (id, name) VALUES
(100, 'Saint-Louis'),
(101, 'Mbour'),
(102, 'Touba'),
(103, 'Ziguinchor'),
(104, 'Kaolack'),
(105, 'Thiès'),
(106, 'Fatick'),
(107, 'Kédougou'),
(108, 'Louga'),
(109, 'Tambacounda');

INSERT IGNORE INTO place (id, name, description, city, region, address, image_url, rating, review_count, latitude, longitude, visit_duration, entry_price, category_id) VALUES
(100, 'Île de Gorée',
 'Petite île au large de Dakar, inscrite au patrimoine mondial de l''UNESCO depuis 1978. Ruelles colorées, maisons à balcons, le Castel et une vue unique sur la baie. Lieu de mémoire de la traite atlantique.',
 'Dakar', 'Dakar', 'Chaloupe depuis la gare maritime du port de Dakar',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Ile-de-goree.jpg/640px-Ile-de-goree.jpg',
 0, 0, 14.6672, -17.3990, 4, NULL, 6),
(101, 'Maison des Esclaves',
 'Bâtiment emblématique de Gorée et sa « porte du voyage sans retour ». Le musée retrace l''histoire de la traite négrière.',
 'Dakar', 'Dakar', 'Rue Saint-Germain, Île de Gorée', NULL,
 0, 0, 14.6667, -17.3980, 1, NULL, 6),
(102, 'Monument de la Renaissance africaine',
 'Statue monumentale de 52 mètres sur la colline des Mamelles, inaugurée en 2010. Ascenseur jusqu''au sommet et panorama sur Dakar.',
 'Dakar', 'Dakar', 'Colline des Mamelles, Ouakam', NULL,
 0, 0, 14.7222, -17.4950, 1.5, NULL, 8),
(103, 'Musée des Civilisations noires',
 'Grand musée ouvert en 2018, consacré aux cultures africaines et de la diaspora : art, histoire, sciences et création contemporaine.',
 'Dakar', 'Dakar', 'Place de la Gare, Dakar Plateau', NULL,
 0, 0, 14.6765, -17.4340, 2, NULL, 1),
(104, 'Musée Théodore Monod d''art africain',
 'Musée de l''IFAN, l''un des plus anciens d''Afrique de l''Ouest : masques, textiles et objets rituels de toute la région.',
 'Dakar', 'Dakar', 'Place Soweto, Dakar Plateau', NULL,
 0, 0, 14.6657, -17.4362, 1.5, NULL, 1),
(105, 'Lac Rose',
 'Le lac Retba, célèbre pour sa couleur rose en saison sèche et ses récolteurs de sel. Balades en pirogue et dunes à proximité.',
 'Dakar', 'Dakar', 'Niaga, à 35 km de Dakar', NULL,
 0, 0, 14.8394, -17.2333, 3, NULL, 5),
(106, 'Mosquée de la Divinité',
 'Mosquée blanche aux deux minarets posée au bord de l''océan à Ouakam, magnifique au coucher du soleil.',
 'Dakar', 'Dakar', 'Corniche de Ouakam', NULL,
 0, 0, 14.7238, -17.5105, 1, 0, 2),
(107, 'Phare des Mamelles',
 'Phare construit en 1864 au sommet d''une colline volcanique. Vue à 360° sur la presqu''île du Cap-Vert.',
 'Dakar', 'Dakar', 'Colline des Mamelles, Ouakam', NULL,
 0, 0, 14.7272, -17.5094, 1, NULL, 6),
(108, 'Village artisanal de Soumbédioune',
 'Marché d''artisanat au bord de la corniche : sculpture, maroquinerie, bijoux et tissus. Retour des pirogues de pêche en fin de journée.',
 'Dakar', 'Dakar', 'Corniche Ouest, Soumbédioune', NULL,
 0, 0, 14.6835, -17.4630, 1, 0, 1),
(109, 'Marché Kermel',
 'Marché couvert du Plateau, reconstruit à l''identique après l''incendie de 1993 : fleurs, fruits, poissons et artisanat.',
 'Dakar', 'Dakar', 'Rue Mohamed V, Dakar Plateau', NULL,
 0, 0, 14.6697, -17.4318, 1, 0, 1),
(110, 'Grande Mosquée de Touba',
 'L''une des plus grandes mosquées d''Afrique subsaharienne, cœur de la confrérie mouride et du Grand Magal.',
 'Touba', 'Diourbel', 'Centre-ville de Touba', NULL,
 0, 0, 14.8605, -15.8795, 2, 0, 2),
(111, 'Grande Mosquée de Tivaouane',
 'Haut lieu de la confrérie tidiane, fondé par Seydi El Hadji Malick Sy. Point central du Gamou annuel.',
 'Tivaouane', 'Thiès', 'Centre-ville de Tivaouane', NULL,
 0, 0, 14.9500, -16.8167, 1.5, 0, 2),
(112, 'Médina Baye',
 'Quartier religieux de Kaolack fondé par Cheikh Ibrahima Niass, avec sa grande mosquée qui accueille des fidèles du monde entier.',
 'Kaolack', 'Kaolack', 'Médina Baye, Kaolack', NULL,
 0, 0, 14.1520, -16.0770, 1.5, 0, 2),
(113, 'Basilique de Popenguine',
 'Sanctuaire marial Notre-Dame de la Délivrance, lieu du grand pèlerinage catholique de la Pentecôte.',
 'Popenguine', 'Thiès', 'Popenguine', NULL,
 0, 0, 14.5531, -17.1131, 1, 0, 2),
(114, 'Île de Saint-Louis',
 'Ancienne capitale de l''AOF, inscrite au patrimoine mondial. Architecture coloniale, quais du fleuve et ambiance du festival de jazz.',
 'Saint-Louis', 'Saint-Louis', 'Île de Saint-Louis', NULL,
 0, 0, 16.0270, -16.5040, 4, NULL, 6),
(115, 'Pont Faidherbe',
 'Pont métallique de plus de 500 mètres reliant l''île de Saint-Louis au continent, symbole de la ville.',
 'Saint-Louis', 'Saint-Louis', 'Avenue Jean Mermoz, Saint-Louis', NULL,
 0, 0, 16.0243, -16.5020, 0.5, 0, 6),
(116, 'Parc national des oiseaux du Djoudj',
 'Troisième réserve ornithologique du monde, patrimoine mondial : pélicans, flamants roses et des millions d''oiseaux migrateurs de novembre à avril.',
 'Saint-Louis', 'Saint-Louis', 'À 60 km au nord de Saint-Louis', NULL,
 0, 0, 16.4000, -16.2800, 4, NULL, 5),
(117, 'Parc national de la Langue de Barbarie',
 'Bande de sable entre le fleuve Sénégal et l''océan : sternes, tortues marines et balades en pirogue.',
 'Saint-Louis', 'Saint-Louis', 'Gandiol, sud de Saint-Louis', NULL,
 0, 0, 15.9333, -16.5000, 3, NULL, 5),
(118, 'Delta du Saloum',
 'Mangroves, bolongs et îles coquillières classés au patrimoine mondial. Pirogue, pêche et observation des oiseaux.',
 'Toubacouta', 'Fatick', 'Toubacouta / Ndangane', NULL,
 0, 0, 13.8000, -16.5500, 6, NULL, 5),
(119, 'Réserve de Bandia',
 'Réserve animalière en savane : girafes, rhinocéros, zèbres et baobabs géants, à une heure de Dakar.',
 'Mbour', 'Thiès', 'Route nationale 1, près de Sindia', NULL,
 0, 0, 14.5833, -17.0167, 2.5, NULL, 7),
(120, 'Désert de Lompoul',
 'Petit désert de dunes ocre entre Dakar et Saint-Louis. Nuit sous la tente mauritanienne, balade à dos de dromadaire.',
 'Lompoul', 'Louga', 'Lompoul-sur-Mer', NULL,
 0, 0, 15.4330, -16.7000, 6, NULL, 7),
(121, 'Île de Fadiouth',
 'Île faite de coquillages reliée à Joal par une passerelle en bois, avec son cimetière mixte chrétien et musulman.',
 'Joal-Fadiouth', 'Thiès', 'Passerelle de Joal', NULL,
 0, 0, 14.1544, -16.8269, 2, NULL, 1),
(122, 'Île de Carabane',
 'Île historique à l''embouchure du fleuve Casamance : ancien comptoir, église bretonne et plages calmes.',
 'Ziguinchor', 'Ziguinchor', 'Embouchure de la Casamance', NULL,
 0, 0, 12.5378, -16.7008, 5, NULL, 6),
(123, 'Parc national du Niokolo-Koba',
 'Le plus grand parc du Sénégal, patrimoine mondial : savane, forêt galerie, hippopotames et antilopes.',
 'Tambacounda', 'Tambacounda', 'Accès par Dar Salam', NULL,
 0, 0, 13.0333, -13.2833, 8, NULL, 5),
(124, 'Cascade de Dindéfélo',
 'Chute d''eau d''environ 100 mètres au pied des falaises du pays bassari, avec bassin naturel pour se baigner.',
 'Kédougou', 'Kédougou', 'Village de Dindéfélo', NULL,
 0, 0, 12.3800, -12.3200, 4, NULL, 7);

INSERT IGNORE INTO hotel (id, name, description, address, city_name, price, rating, review_count, image_url, latitude, longitude, category_id) VALUES
(100, 'Radisson Blu Hotel Dakar Sea Plaza', 'Hôtel contemporain face à l''océan sur la Corniche Ouest, avec piscine à débordement et accès au centre commercial Sea Plaza.', 'Corniche Ouest, Dakar', 'Dakar', 150000, 0, 0, NULL, 14.6853, -17.4708, 8),
(101, 'King Fahd Palace', 'Grand complexe hôtelier à la pointe des Almadies, jardins, piscines et accès à la mer.', 'Pointe des Almadies, Dakar', 'Dakar', 140000, 0, 0, NULL, 14.7389, -17.5139, 4),
(102, 'Pullman Dakar Teranga', 'Hôtel du Plateau proche des ministères et du port, vue sur l''île de Gorée.', 'Place de l''Indépendance, Dakar', 'Dakar', 130000, 0, 0, NULL, 14.6683, -17.4302, 8),
(103, 'Hôtel de la Poste', 'Hôtel historique de l''île, ancien repaire des pilotes de l''Aéropostale dont Mermoz.', 'Île de Saint-Louis', 'Saint-Louis', 45000, 0, 0, NULL, 16.0251, -16.5047, 6),
(104, 'Hôtel La Résidence', 'Maison saint-louisienne rénovée au cœur de l''île, décor d''époque et cuisine locale.', 'Avenue Blaise Diagne, Saint-Louis', 'Saint-Louis', 50000, 0, 0, NULL, 16.0262, -16.5047, 6),
(105, 'Lamantin Beach Resort & Spa', 'Resort en bord de plage à Saly avec spa, plusieurs piscines et activités nautiques.', 'Saly Portudal', 'Mbour', 120000, 0, 0, NULL, 14.4378, -16.9933, 4),
(106, 'Royal Baobab', 'Hôtel au bord de la lagune de la Somone, entre mangrove et océan.', 'La Somone', 'Mbour', 90000, 0, 0, NULL, 14.4840, -17.0800, 4),
(107, 'Keur Saloum', 'Hôtel en bungalows à Toubacouta, point de départ idéal pour les bolongs du delta du Saloum.', 'Toubacouta', 'Fatick', 55000, 0, 0, NULL, 13.7869, -16.4847, 5),
(108, 'Hôtel Kadiandoumagne', 'Hôtel au bord du fleuve Casamance, terrasse sur les palétuviers.', 'Rue du Fleuve, Ziguinchor', 'Ziguinchor', 40000, 0, 0, NULL, 12.5880, -16.2720, 5),
(109, 'Écolodge de Lompoul', 'Campement de tentes mauritaniennes au milieu des dunes, dîner sous les étoiles.', 'Désert de Lompoul', 'Louga', 45000, 0, 0, NULL, 15.4330, -16.7010, 7);

INSERT IGNORE INTO restaurant (id, name, description, address, city, rating, review_count, image_url, latitude, longitude, category_id) VALUES
(100, 'Chez Loutcha', 'Adresse populaire du Plateau pour les plats sénégalais et capverdiens : thiéboudienne, yassa, cachupa.', 'Rue Moussé Diop, Dakar Plateau', 'Dakar', 0, 0, NULL, 14.6720, -17.4380, 3),
(101, 'Le Lagon 1', 'Restaurant de poissons et fruits de mer sur pilotis, au-dessus de l''eau face à Gorée.', 'Route de la Corniche Est, Dakar', 'Dakar', 0, 0, NULL, 14.6640, -17.4270, 3),
(102, 'La Calebasse', 'Cuisine sénégalaise revisitée dans un cadre décoré d''artisanat, terrasse avec vue sur les Mamelles.', 'Route des Mamelles, Ouakam', 'Dakar', 0, 0, NULL, 14.7230, -17.5000, 3),
(103, 'Le Flamingo', 'Restaurant au bord du fleuve sur l''île de Saint-Louis, avec vue sur le pont Faidherbe.', 'Quai Bacre Waly Gueye, Saint-Louis', 'Saint-Louis', 0, 0, NULL, 16.0250, -16.5030, 3);

INSERT IGNORE INTO beach (id, name, description, address, city, rating, review_count, image_url, latitude, longitude, category_id) VALUES
(100, 'Plage de Cap Skirring', 'Longue plage de sable blanc bordée de cocotiers, l''une des plus belles du pays.', 'Cap Skirring', 'Ziguinchor', 0, 0, NULL, 12.3933, -16.7461, 4),
(101, 'Plage de la Somone', 'Plage calme à l''embouchure de la lagune, idéale pour la baignade et l''observation des oiseaux.', 'La Somone', 'Mbour', 0, 0, NULL, 14.4833, -17.0833, 4),
(102, 'Plage de Popenguine', 'Petite plage nichée au pied des falaises, à côté de la réserve naturelle.', 'Popenguine', 'Thiès', 0, 0, NULL, 14.5500, -17.1100, 4),
(103, 'Plage de Toubab Dialaw', 'Plage entourée de falaises ocre, ambiance artistique et villages de pêcheurs.', 'Toubab Dialaw', 'Thiès', 0, 0, NULL, 14.6000, -17.1500, 4),
(104, 'Plage des Almadies', 'Plage de la pointe la plus à l''ouest de l''Afrique continentale, prisée des surfeurs.', 'Pointe des Almadies', 'Dakar', 0, 0, NULL, 14.7447, -17.5300, 4);

UPDATE beach SET latitude = 14.7505, longitude = -17.5137 WHERE id = 1 AND latitude IS NULL;
UPDATE beach SET latitude = 14.4486, longitude = -17.0103 WHERE id = 2 AND latitude IS NULL;
UPDATE beach SET latitude = 14.7553, longitude = -17.5167 WHERE id = 3 AND latitude IS NULL;
UPDATE hotel SET latitude = 14.6797, longitude = -17.4669 WHERE id IN (4, 5) AND latitude IS NULL;
UPDATE restaurant SET latitude = 14.7488, longitude = -17.5136 WHERE id = 1 AND latitude IS NULL;
UPDATE restaurant SET latitude = 14.7440, longitude = -17.5250 WHERE id = 16 AND latitude IS NULL;

UPDATE place SET sub_type = 'Île' WHERE id IN (100, 121, 122) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Musée' WHERE id IN (101, 103, 104) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Monument' WHERE id IN (102, 107, 115) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Lac' WHERE id IN (105) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Mosquée' WHERE id IN (106, 110, 111) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Marché artisanal' WHERE id IN (108) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Marché' WHERE id IN (109) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Lieu de pèlerinage' WHERE id IN (112) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Église' WHERE id IN (113) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Ville historique' WHERE id IN (114) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Parc national' WHERE id IN (116, 117, 123) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Réserve naturelle' WHERE id IN (118) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Réserve animalière' WHERE id IN (119) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Désert' WHERE id IN (120) AND sub_type IS NULL;
UPDATE place SET sub_type = 'Cascade' WHERE id IN (124) AND sub_type IS NULL;

UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Monument_renaissance.jpg?width=1200' WHERE id = 102 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Lac_Rose_in_Senegal.jpg?width=1200' WHERE id = 105 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Touba_moschee.jpg?width=1200' WHERE id = 110 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Island_of_Saint-Louis-113799.jpg?width=1200' WHERE id = 114 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Saintlouis_pont_Faidherbe.jpg?width=1200' WHERE id = 115 AND image_url IS NULL;

UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Maison_des_Esclaves_04045.JPG?width=1200' WHERE id = 101 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Mus%C3%A9e_des_civilisations_noires_2022.jpg?width=1200' WHERE id = 103 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Mus%C3%A9e_d''art_africain_Th%C3%A9odore_Monod.jpg?width=1200' WHERE id = 104 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Ouakam-Mosqu%C3%A9e_de_la_Divinit%C3%A9_(3).jpg?width=1200' WHERE id = 106 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/PhareMamelles4.JPG?width=1200' WHERE id = 107 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/La_mosqu%C3%A9e_de_serigne_Babacar_sy.jpg?width=1200' WHERE id = 111 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/MedinaBaayMosque.jpg?width=1200' WHERE id = 112 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/PopenguineChurch.JPG?width=1200' WHERE id = 113 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/P%C3%A9licans_au_Parc_national_du_Djoudj.jpg?width=1200' WHERE id = 116 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Le_nouveau_embouchure_de_Saint-Louis_situant_au_Parc_National_de_la_Langue_de_Barbarie_(PNLB)_05.jpg?width=1200' WHERE id = 117 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Mangrove_%C3%AEle_du_Saloum_S%C3%A9n%C3%A9gal.jpg?width=1200' WHERE id = 118 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Girafe_dans_la_r%C3%A9serve_de_Bandia_S%C3%A9n%C3%A9gal_01.jpg?width=1200' WHERE id = 119 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/2017-06_Lompoul_Desert_2.jpg?width=1200' WHERE id = 120 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Pont_de_l%E2%80%99Aire_Marine_Prot%C3%A9g%C3%A9e_de_Joal-Fadiouth_18.jpg?width=1200' WHERE id = 121 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Carabane-Bolongs.JPG?width=1200' WHERE id = 122 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Paysage_du_parc_Niokolo_Koba_du_S%C3%A9n%C3%A9gal.jpg?width=1200' WHERE id = 123 AND image_url IS NULL;
UPDATE place SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Cascade_de_Dindefelo_02.jpg?width=1200' WHERE id = 124 AND image_url IS NULL;
UPDATE beach SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Cap-Skirring-Beach-2007.jpg?width=1200' WHERE id = 100 AND image_url IS NULL;
UPDATE beach SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Lagune_de_LA_SOMONE.jpg?width=1200' WHERE id = 101 AND image_url IS NULL;
UPDATE beach SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Plage_r%C3%A9serve_naturelle_de_Popenguine,_Thies_S%C3%A9n%C3%A9gal,_Juin_2022.jpg?width=1200' WHERE id = 102 AND image_url IS NULL;
UPDATE beach SET image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Toubab_Dialaw_294A2254_Senegal.jpg?width=1200' WHERE id = 103 AND image_url IS NULL;

INSERT IGNORE INTO calendar_event (id, name, community, description, advice, city, place_id, start_date, end_date, confirmed) VALUES
(100, 'Grand Magal de Touba', 'Mouride', 'Commémoration du départ en exil de Cheikh Ahmadou Bamba, fondateur du mouridisme, le 18 Safar. Plusieurs millions de pèlerins convergent vers Touba et sa Grande Mosquée, ce qui en fait le plus grand rassemblement du pays.', 'Touba interdit l''alcool et le tabac sur tout son territoire. Prévoir une tenue couverte, de l''eau et beaucoup de patience sur la route : partir la veille au plus tard. L''hébergement se fait surtout chez l''habitant, à organiser à l''avance.', 'Touba', 110, '2026-08-02', '2026-08-02', 1),
(101, 'Gamou de Tivaouane', 'Tidiane', 'Le Gamou célèbre la naissance du Prophète Mohammed (12 Rabi al-Awwal). À Tivaouane, capitale de la Tidjaniya fondée par El Hadji Malick Sy, la nuit du Mawlid est précédée de plusieurs jours de récitation du Burd.', 'Les nuits de récitation sont ouvertes au public dans le calme. Tenue sobre conseillée. Les transports depuis Dakar et Thiès sont saturés le jour J : privilégier les jours précédents.', 'Tivaouane', 111, '2026-08-25', '2026-08-25', 1),
(102, 'Gamou de Médina Baye', 'Tidiane (Niassène)', 'Le Gamou de la famille de Cheikh Ibrahima Niass à Médina Baye (Kaolack) réunit des fidèles venus de toute l''Afrique de l''Ouest, notamment du Nigeria, du Ghana et de Mauritanie.', 'Kaolack est à environ trois heures de Dakar. Réserver tôt l''hébergement en ville, il se remplit vite. Tenue sobre conseillée.', 'Kaolack', 112, '2026-08-28', '2026-08-28', 1),
(103, 'Pèlerinage marial de Popenguine', 'Catholique', 'Pèlerinage catholique à Notre-Dame de la Délivrande, organisé chaque week-end de Pentecôte depuis 1888. Des dizaines de milliers de jeunes marchent jusqu''au sanctuaire avant la grande messe du lundi.', 'Des bus supplémentaires partent de Dakar pendant le week-end. Pour dormir au calme, chercher un hébergement à Somone, Saly ou Toubab Dialaw. Prévoir chapeau et eau pour la marche.', 'Popenguine', 113, '2026-05-23', '2026-05-25', 1),
(104, 'Pèlerinage marial de Popenguine', 'Catholique', 'Pèlerinage catholique à Notre-Dame de la Délivrande, organisé chaque week-end de Pentecôte depuis 1888. Des dizaines de milliers de jeunes marchent jusqu''au sanctuaire avant la grande messe du lundi.', 'Des bus supplémentaires partent de Dakar pendant le week-end. Pour dormir au calme, chercher un hébergement à Somone, Saly ou Toubab Dialaw. Prévoir chapeau et eau pour la marche.', 'Popenguine', 113, '2027-05-15', '2027-05-17', 0),
(105, 'Grand Magal de Touba', 'Mouride', 'Commémoration du départ en exil de Cheikh Ahmadou Bamba, fondateur du mouridisme, le 18 Safar. Plusieurs millions de pèlerins convergent vers Touba et sa Grande Mosquée, ce qui en fait le plus grand rassemblement du pays.', 'Touba interdit l''alcool et le tabac sur tout son territoire. Prévoir une tenue couverte, de l''eau et beaucoup de patience sur la route : partir la veille au plus tard. L''hébergement se fait surtout chez l''habitant, à organiser à l''avance.', 'Touba', 110, '2027-07-23', '2027-07-23', 0),
(106, 'Gamou de Tivaouane', 'Tidiane', 'Le Gamou célèbre la naissance du Prophète Mohammed (12 Rabi al-Awwal). À Tivaouane, capitale de la Tidjaniya fondée par El Hadji Malick Sy, la nuit du Mawlid est précédée de plusieurs jours de récitation du Burd.', 'Les nuits de récitation sont ouvertes au public dans le calme. Tenue sobre conseillée. Les transports depuis Dakar et Thiès sont saturés le jour J : privilégier les jours précédents.', 'Tivaouane', 111, '2027-08-14', '2027-08-14', 0),
(107, 'Gamou de Médina Baye', 'Tidiane (Niassène)', 'Le Gamou de la famille de Cheikh Ibrahima Niass à Médina Baye (Kaolack) réunit des fidèles venus de toute l''Afrique de l''Ouest, notamment du Nigeria, du Ghana et de Mauritanie.', 'Kaolack est à environ trois heures de Dakar. Réserver tôt l''hébergement en ville, il se remplit vite. Tenue sobre conseillée.', 'Kaolack', 112, '2027-08-17', '2027-08-17', 0);
