import '../core/models/toledo_spot.dart';
import '../core/models/spot_category.dart';

/// Phase 1 static data — 10 hardcoded Toledo spots.
final List<ToledoSpot> toledoSpots = const [
  ToledoSpot(
    id: 'din_001',
    name: 'Kato Ramen',
    latitude: 41.6528,
    longitude: -83.5379,
    category: SpotCategory.dining,
    vibeCheck: 'Late-night bowl perfection',
    description:
        'Authentic Japanese ramen with rich tonkotsu broth and handmade noodles',
  ),
  ToledoSpot(
    id: 'din_002',
    name: 'Night Owl Diner',
    latitude: 41.6639,
    longitude: -83.5552,
    category: SpotCategory.dining,
    vibeCheck: 'Classic diner vibes, open late',
    description:
        '24-hour comfort food with generous portions and nostalgic atmosphere',
  ),
  ToledoSpot(
    id: 'din_003',
    name: 'Kyoto Ka',
    latitude: 41.6498,
    longitude: -83.5401,
    category: SpotCategory.dining,
    vibeCheck: 'Upscale Japanese fusion',
    description:
        'Modern Japanese cuisine with creative presentations and premium ingredients',
  ),
  ToledoSpot(
    id: 'din_004',
    name: 'Nagoya',
    latitude: 41.6612,
    longitude: -83.5525,
    category: SpotCategory.dining,
    vibeCheck: 'Sushi bar excellence',
    description: 'Traditional sushi and sashimi with skilled itamae chefs',
  ),
  ToledoSpot(
    id: 'din_005',
    name: 'Top Pot Korean BBQ',
    latitude: 41.6545,
    longitude: -83.5432,
    category: SpotCategory.dining,
    vibeCheck: 'Interactive grill-your-own experience',
    description:
        'All-you-can-eat Korean BBQ with table grills and banchan variety',
  ),
  ToledoSpot(
    id: 'rec_001',
    name: 'Ottawa Park Basketball Courts',
    latitude: 41.6689,
    longitude: -83.6012,
    category: SpotCategory.recreation,
    vibeCheck: 'Pickup games and cardio runs',
    description:
        'Well-maintained outdoor courts with regular pickup basketball games',
  ),
  ToledoSpot(
    id: 'rec_002',
    name: 'Glass City Metropark',
    latitude: 41.6801,
    longitude: -83.4523,
    category: SpotCategory.recreation,
    vibeCheck: 'Waterfront trails and skyline views',
    description:
        'Urban park along Maumee River with walking trails and event space',
  ),
  ToledoSpot(
    id: 'rec_003',
    name: 'Toledo Zoo',
    latitude: 41.6234,
    longitude: -83.5512,
    category: SpotCategory.entertainment,
    vibeCheck: 'World-class exhibits year-round',
    description:
        'Historic zoo with diverse animal collection and botanical gardens',
  ),
  ToledoSpot(
    id: 'fit_001',
    name: 'YMCA Perrysburg',
    latitude: 41.5570,
    longitude: -83.6270,
    category: SpotCategory.fitness,
    vibeCheck: 'Full-service gym and pool',
    description:
        'Modern fitness facility with cardio equipment, weights, and aquatic center',
  ),
  ToledoSpot(
    id: 'caf_001',
    name: 'The Onyx Cafe',
    latitude: 41.6523,
    longitude: -83.5489,
    category: SpotCategory.cafe,
    vibeCheck: 'Specialty coffee and study spot',
    description: 'Locally roasted coffee with cozy atmosphere for remote work',
  ),
];
