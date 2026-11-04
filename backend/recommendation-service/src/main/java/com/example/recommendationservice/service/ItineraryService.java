package com.example.recommendationservice.service;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ItineraryService {

    static final double HOURS_PER_DAY = 7;
    static final double HOTEL_RADIUS_KM = 60;
    static final double RESTAURANT_RADIUS_KM = 30;

    // deux villes plus proches que ça peuvent partager une même journée
    static final double SAME_DAY_KM = 70;

    static final double DISTANCE_PENALTY_KM = 150;

    // vol d'oiseau -> route, et vitesse moyenne sur les nationales
    static final double ROAD_FACTOR = 1.3;
    static final double ROAD_KMH = 55;

    // au-delà, la ville demande au moins deux jours restants (trajet + visite)
    static final double FAR_KM = 100;

    private static final double[] DAKAR = {14.6928, -17.4467};

    private final CatalogGateway catalogGateway;

    public ItineraryService(CatalogGateway catalogGateway) {
        this.catalogGateway = catalogGateway;
    }

    public Map<String, Object> build(int days, List<String> categories, String startCity) {
        days = Math.max(1, Math.min(days, 10));
        Set<String> wanted = categories == null ? Set.of()
                : categories.stream().map(String::toUpperCase).collect(Collectors.toSet());

        List<Map<String, Object>> catalog = catalogGateway.catalog();
        List<Map<String, Object>> places = located(catalog, "place");
        places.addAll(located(catalog, "beach"));
        List<Map<String, Object>> hotels = located(catalog, "hotel");
        List<Map<String, Object>> restaurants = located(catalog, "restaurant");

        List<Map<String, Object>> candidates = places.stream()
                .filter(p -> wanted.isEmpty() || wanted.contains(str(p.get("category"))))
                .collect(Collectors.toList());
        if (candidates.isEmpty()) {
            candidates = places;
        }

        Map<String, List<Map<String, Object>>> byCity = new LinkedHashMap<>();
        for (Map<String, Object> p : candidates) {
            byCity.computeIfAbsent(str(p.get("city")), c -> new ArrayList<>()).add(p);
        }
        byCity.values().forEach(list -> list.sort(
                Comparator.comparingDouble((Map<String, Object> p) -> score(p, wanted)).reversed()));

        double[] start = startPosition(startCity, places);
        double[] position = start;
        List<Map<String, Object>> plan = new ArrayList<>();
        double totalKm = 0;

        Deque<Map<String, Object>> queue = new ArrayDeque<>();
        DayBuilder day = new DayBuilder(1);

        while (day.number <= days) {
            if (queue.isEmpty()) {
                if (byCity.isEmpty()) {
                    break;
                }
                String city = nextCity(byCity, position, start, wanted, days - day.number + 1);
                if (city == null) {
                    break;
                }
                double km = distance(position, centroid(byCity.get(city)));
                if (!day.visits.isEmpty() && (day.hours >= HOURS_PER_DAY / 2 || km > SAME_DAY_KM)) {
                    plan.add(day.build(hotels, restaurants));
                    day = new DayBuilder(day.number + 1);
                    continue;
                }
                queue.addAll(byCity.remove(city));
                continue;
            }

            Map<String, Object> next = queue.peek();
            double km = distance(position, coords(next));
            if (!day.visits.isEmpty() && day.hours + travelHours(km) + duration(next) > HOURS_PER_DAY) {
                plan.add(day.build(hotels, restaurants));
                day = new DayBuilder(day.number + 1);
                continue;
            }

            queue.poll();
            totalKm += km;
            position = coords(next);
            day.add(next, duration(next), km);
        }
        if (!day.visits.isEmpty() && day.number <= days) {
            plan.add(day.build(hotels, restaurants));
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("days", plan);
        result.put("totalKm", Math.round(totalKm * ROAD_FACTOR));
        result.put("cities", plan.stream()
                .flatMap(d -> ((List<?>) d.get("cities")).stream())
                .distinct()
                .toList());
        return result;
    }

    private class DayBuilder {
        final int number;
        final List<Map<String, Object>> visits = new ArrayList<>();
        final Set<String> cities = new LinkedHashSet<>();
        double hours;
        double km;

        DayBuilder(int number) {
            this.number = number;
        }

        void add(Map<String, Object> place, double duration, double travelKm) {
            visits.add(place);
            cities.add(str(place.get("city")));
            hours += duration + travelHours(travelKm);
            km += travelKm;
        }

        Map<String, Object> build(List<Map<String, Object>> hotels, List<Map<String, Object>> restaurants) {
            double[] center = centroid(visits);
            Map<String, Object> d = new LinkedHashMap<>();
            d.put("day", number);
            d.put("city", String.join(" → ", cities));
            d.put("cities", new ArrayList<>(cities));
            d.put("travelKm", Math.round(km * ROAD_FACTOR));
            d.put("driveHours", Math.round(travelHours(km) * 2) / 2.0);
            d.put("hours", hours);
            d.put("places", visits);
            d.put("hotel", nearest(hotels, coords(visits.get(visits.size() - 1)), HOTEL_RADIUS_KM));
            d.put("restaurant", nearest(restaurants, center, RESTAURANT_RADIUS_KM));
            return d;
        }
    }

    private String nextCity(Map<String, List<Map<String, Object>>> byCity, double[] position, double[] start,
                            Set<String> wanted, int daysLeft) {
        String best = null;
        double bestValue = -1;
        for (Map.Entry<String, List<Map<String, Object>>> e : byCity.entrySet()) {
            double[] center = centroid(e.getValue());
            if (daysLeft < 2 && distance(start, center) > FAR_KM) {
                continue;
            }
            double interest = e.getValue().stream().limit(3).mapToDouble(p -> score(p, wanted)).sum();
            double km = distance(position, center);
            double value = interest / (1 + km / DISTANCE_PENALTY_KM);
            if (value > bestValue) {
                bestValue = value;
                best = e.getKey();
            }
        }
        return best;
    }

    private double[] startPosition(String startCity, List<Map<String, Object>> places) {
        if (startCity == null || startCity.isBlank()) {
            return DAKAR;
        }
        List<Map<String, Object>> inCity = places.stream()
                .filter(p -> str(p.get("city")).equalsIgnoreCase(startCity.trim()))
                .toList();
        return inCity.isEmpty() ? DAKAR : centroid(inCity);
    }

    static double travelHours(double km) {
        return km * ROAD_FACTOR / ROAD_KMH;
    }

    double score(Map<String, Object> place, Set<String> wanted) {
        double match = wanted.isEmpty() || wanted.contains(str(place.get("category"))) ? 1 : 0.2;
        double rating = place.get("rating") == null ? 0 : Double.parseDouble(place.get("rating").toString());
        return 0.7 * match + 0.3 * rating / 5;
    }

    private Map<String, Object> nearest(List<Map<String, Object>> items, double[] center, double radiusKm) {
        Map<String, Object> best = null;
        double bestKm = radiusKm;
        for (Map<String, Object> item : items) {
            double km = distance(center, coords(item));
            if (km <= bestKm) {
                bestKm = km;
                best = item;
            }
        }
        return best;
    }

    private List<Map<String, Object>> located(List<Map<String, Object>> catalog, String type) {
        return catalog.stream()
                .filter(i -> type.equals(i.get("type")))
                .filter(i -> i.get("latitude") != null && i.get("longitude") != null)
                .collect(Collectors.toList());
    }

    private double duration(Map<String, Object> place) {
        Object d = place.get("visitDuration");
        if (d != null) {
            return Double.parseDouble(d.toString());
        }
        return "beach".equals(place.get("type")) ? 3 : 2;
    }

    private double[] coords(Map<String, Object> item) {
        return new double[]{
                Double.parseDouble(item.get("latitude").toString()),
                Double.parseDouble(item.get("longitude").toString())
        };
    }

    private double[] centroid(List<Map<String, Object>> items) {
        double lat = 0, lng = 0;
        for (Map<String, Object> i : items) {
            double[] c = coords(i);
            lat += c[0];
            lng += c[1];
        }
        return new double[]{lat / items.size(), lng / items.size()};
    }

    static double distance(double[] a, double[] b) {
        double r = 6371;
        double dLat = Math.toRadians(b[0] - a[0]);
        double dLng = Math.toRadians(b[1] - a[1]);
        double h = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(a[0])) * Math.cos(Math.toRadians(b[0]))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.asin(Math.sqrt(h));
    }

    private static String str(Object o) {
        return o == null ? "" : o.toString().trim();
    }
}
