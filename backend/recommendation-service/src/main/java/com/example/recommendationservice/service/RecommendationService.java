package com.example.recommendationservice.service;

import com.example.recommendationservice.entity.Favorite;
import com.example.recommendationservice.entity.HotelLike;
import com.example.recommendationservice.repository.FavoriteRepository;
import com.example.recommendationservice.repository.HotelLikeRepository;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class RecommendationService {

    // poids de chaque signal dans le profil utilisateur
    static final double W_RESERVATION = 4;
    static final double W_FAVORITE = 3;
    static final double W_LIKE = 2;
    static final double W_DISLIKE = -1.5;
    static final double W_DECLARED = 2;

    // poids de chaque composante dans le score final
    static final double S_CATEGORY = 0.45;
    static final double S_CITY = 0.20;
    static final double S_TYPE = 0.10;
    static final double S_RATING = 0.25;

    private final HotelLikeRepository hotelLikeRepository;
    private final FavoriteRepository favoriteRepository;
    private final CatalogGateway catalogGateway;

    public RecommendationService(HotelLikeRepository hotelLikeRepository,
                                 FavoriteRepository favoriteRepository,
                                 CatalogGateway catalogGateway) {
        this.hotelLikeRepository = hotelLikeRepository;
        this.favoriteRepository = favoriteRepository;
        this.catalogGateway = catalogGateway;
    }

    public HotelLike saveLike(HotelLike like) {
        return hotelLikeRepository.save(like);
    }

    public List<HotelLike> getUserLikes(Long userId) {
        return hotelLikeRepository.findByUserId(userId);
    }

    public Favorite addFavorite(Favorite favorite) {
        return favoriteRepository
                .findByUserIdAndItemIdAndItemType(favorite.getUserId(), favorite.getItemId(), favorite.getItemType())
                .orElseGet(() -> favoriteRepository.save(favorite));
    }

    public List<Favorite> getFavorites(Long userId) {
        return favoriteRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public void removeFavorite(Long userId, Long itemId, String itemType) {
        favoriteRepository.deleteByUserIdAndItemIdAndItemType(userId, itemId, itemType);
    }

    public List<Map<String, Object>> getCatalog() {
        return catalogGateway.catalog();
    }

    public List<Map<String, Object>> recommend(Long userId, int limit, List<String> declaredCategories) {
        List<Map<String, Object>> catalog = getCatalog();
        Map<String, Map<String, Object>> byKey = new HashMap<>();
        for (Map<String, Object> item : catalog) {
            byKey.put(key(item.get("type"), item.get("id")), item);
        }

        Profile profile = new Profile();
        Set<String> alreadySeen = new HashSet<>();

        for (Favorite f : favoriteRepository.findByUserIdOrderByCreatedAtDesc(userId)) {
            String k = key(f.getItemType(), f.getItemId());
            alreadySeen.add(k);
            profile.add(byKey.get(k), W_FAVORITE);
        }

        for (HotelLike like : hotelLikeRepository.findByUserId(userId)) {
            String k = key("hotel", like.getHotelId());
            profile.add(byKey.get(k), Boolean.TRUE.equals(like.getLiked()) ? W_LIKE : W_DISLIKE);
        }

        for (Map<String, Object> r : userReservations(userId)) {
            if ("ANNULEE".equals(r.get("status"))) {
                continue;
            }
            String k = key("hotel", r.get("hotelId"));
            alreadySeen.add(k);
            profile.add(byKey.get(k), W_RESERVATION);
        }

        if (declaredCategories != null) {
            for (String c : declaredCategories) {
                profile.categories.merge(c.toUpperCase(), W_DECLARED, Double::sum);
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();

        if (profile.isEmpty()) {
            catalog.stream()
                    .sorted(Comparator.comparingDouble(this::rating).reversed())
                    .forEach(item -> result.add(withScore(item, rating(item) / 5, "Parmi les lieux les mieux notés")));
            return diversify(result, limit);
        }

        double maxCat = profile.max(profile.categories);
        double maxCity = profile.max(profile.cities);
        double maxType = profile.max(profile.types);

        for (Map<String, Object> item : catalog) {
            if (alreadySeen.contains(key(item.get("type"), item.get("id")))) {
                continue;
            }
            String category = str(item.get("category"));
            String city = str(item.get("city"));
            String type = str(item.get("type"));

            double cat = ratio(profile.categories.get(category), maxCat);
            double cityScore = ratio(profile.cities.get(city), maxCity);
            double typeScore = ratio(profile.types.get(type), maxType);
            double ratingScore = rating(item) / 5;

            double score = S_CATEGORY * cat + S_CITY * cityScore + S_TYPE * typeScore + S_RATING * ratingScore;

            String reason;
            if (S_CATEGORY * cat >= S_CITY * cityScore && cat > 0) {
                reason = "Parce que vous aimez les lieux " + category.toLowerCase();
            } else if (cityScore > 0) {
                reason = "Vous vous intéressez à " + city;
            } else {
                reason = "Très bien noté par les voyageurs";
            }
            result.add(withScore(item, score, reason));
        }

        result.sort(Comparator.comparingDouble((Map<String, Object> m) -> (double) m.get("score")).reversed());
        return result.subList(0, Math.min(limit, result.size()));
    }

    private List<Map<String, Object>> userReservations(Long userId) {
        return catalogGateway.reservations(userId);
    }

    private List<Map<String, Object>> diversify(List<Map<String, Object>> sorted, int limit) {
        Map<String, Deque<Map<String, Object>>> byType = new LinkedHashMap<>();
        for (Map<String, Object> item : sorted) {
            byType.computeIfAbsent(str(item.get("type")), t -> new ArrayDeque<>()).add(item);
        }
        List<Map<String, Object>> out = new ArrayList<>();
        while (out.size() < limit && byType.values().stream().anyMatch(q -> !q.isEmpty())) {
            for (Deque<Map<String, Object>> q : byType.values()) {
                if (!q.isEmpty() && out.size() < limit) {
                    out.add(q.poll());
                }
            }
        }
        return out;
    }

    private Map<String, Object> withScore(Map<String, Object> item, double score, String reason) {
        Map<String, Object> copy = new HashMap<>(item);
        copy.put("score", Math.round(score * 1000) / 1000.0);
        copy.put("reason", reason);
        return copy;
    }

    double rating(Map<String, Object> item) {
        Object r = item.get("rating");
        return r == null ? 0 : Double.parseDouble(r.toString());
    }

    static String key(Object type, Object id) {
        return str(type) + ":" + (id == null ? "" : Long.valueOf(id.toString()));
    }

    static String str(Object o) {
        return o == null ? "" : o.toString().trim();
    }

    private static double ratio(Double value, double max) {
        if (value == null || value <= 0 || max <= 0) {
            return 0;
        }
        return value / max;
    }

    static class Profile {
        final Map<String, Double> categories = new HashMap<>();
        final Map<String, Double> cities = new HashMap<>();
        final Map<String, Double> types = new HashMap<>();

        void add(Map<String, Object> item, double weight) {
            if (item == null) {
                return;
            }
            String category = str(item.get("category"));
            if (!category.isEmpty()) {
                categories.merge(category, weight, Double::sum);
            }
            String city = str(item.get("city"));
            if (!city.isEmpty()) {
                cities.merge(city, weight, Double::sum);
            }
            types.merge(str(item.get("type")), weight, Double::sum);
        }

        boolean isEmpty() {
            return categories.values().stream().noneMatch(v -> v > 0)
                    && cities.values().stream().noneMatch(v -> v > 0);
        }

        double max(Map<String, Double> map) {
            return map.values().stream().mapToDouble(Double::doubleValue).max().orElse(0);
        }
    }
}
