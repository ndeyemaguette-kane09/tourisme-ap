package com.example.recommendationservice.service;

import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ItineraryServiceTest {

    private Map<String, Object> item(String type, long id, String city, String category,
                                     double lat, double lng, Double duration) {
        Map<String, Object> m = new HashMap<>();
        m.put("type", type);
        m.put("id", id);
        m.put("name", type + id);
        m.put("city", city);
        m.put("category", category);
        m.put("latitude", lat);
        m.put("longitude", lng);
        m.put("rating", 4.0);
        if (duration != null) {
            m.put("visitDuration", duration);
        }
        return m;
    }

    private ItineraryService service(List<Map<String, Object>> catalog) {
        CatalogGateway gateway = mock(CatalogGateway.class);
        when(gateway.catalog()).thenReturn(catalog);
        return new ItineraryService(gateway);
    }

    @Test
    void keepsOnlyWantedCategoriesAndRespectsDayCount() {
        ItineraryService service = service(List.of(
                item("place", 1, "Dakar", "HISTORIQUE", 14.667, -17.399, 4.0),
                item("place", 2, "Dakar", "NATURE", 14.839, -17.233, 3.0),
                item("place", 3, "Saint-Louis", "NATURE", 16.400, -16.280, 4.0),
                item("place", 4, "Toubacouta", "NATURE", 13.800, -16.550, 6.0),
                item("hotel", 10, "Saint-Louis", "HISTORIQUE", 16.025, -16.505, null)
        ));

        Map<String, Object> result = service.build(2, List.of("nature"), "Dakar");
        List<?> days = (List<?>) result.get("days");

        assertEquals(2, days.size());
        for (Object d : days) {
            for (Object p : (List<?>) ((Map<?, ?>) d).get("places")) {
                assertEquals("NATURE", ((Map<?, ?>) p).get("category"));
            }
        }
    }

    @Test
    void groupsShortVisitsOfNearbyCitiesInOneDay() {
        ItineraryService service = service(List.of(
                item("place", 1, "Dakar", "RELIGIEUX", 14.724, -17.511, 1.0),
                item("place", 2, "Popenguine", "RELIGIEUX", 14.553, -17.113, 1.0)
        ));

        Map<String, Object> result = service.build(3, List.of("RELIGIEUX"), "Dakar");
        List<?> days = (List<?>) result.get("days");

        assertEquals(1, days.size());
        assertEquals(2, ((List<?>) ((Map<?, ?>) days.get(0)).get("places")).size());
    }

    @Test
    void suggestsNearestHotelOnly() {
        ItineraryService service = service(List.of(
                item("place", 1, "Saint-Louis", "HISTORIQUE", 16.027, -16.504, 3.0),
                item("hotel", 10, "Saint-Louis", "HISTORIQUE", 16.025, -16.505, null),
                item("hotel", 11, "Dakar", "MODERNE", 14.685, -17.471, null)
        ));

        Map<String, Object> day = (Map<String, Object>) ((List<?>) service.build(1, null, null).get("days")).get(0);

        assertEquals(10L, ((Map<?, ?>) day.get("hotel")).get("id"));
    }

    @Test
    void distanceDakarSaintLouisIsAbout200Km() {
        double km = ItineraryService.distance(new double[]{14.6928, -17.4467}, new double[]{16.0244, -16.5050});
        assertTrue(km > 170 && km < 210);
    }
}
