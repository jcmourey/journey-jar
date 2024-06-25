//
//  TripAdvisorLocation.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 04/05/2024.
//

import Foundation

/// TripAdvisor Location Search
/// https://api.content.tripadvisor.com/api/v1/location/search?searchQuery=Pigeot&key=<XXX>
//{
//      "location_id": "1335238",
//      "name": "La Pigeot",
//      "address_obj": {
//        "street1": "16 rue Alexis Julien",
//        "street2": "",
//        "city": "Valbonne",
//        "country": "France",
//        "postalcode": "06560",
//        "address_string": "16 rue Alexis Julien, 06560 Valbonne France"
//      }

struct TripAdvisorLocationSearchResult: Codable {
    let data: [TripAdvisorLocation]
}

struct TripAdvisorLocation: Codable {
    let locationId: String
    let name: String
    let addressObj: TripAdvisorAddress
}

struct TripAdvisorAddress: Codable {
    let street1: String
    let street2: String
    let city: String
    let country: String
    let postalcode: String
    let addressString: String
}

/// TripAdvisor Location details
/// https://api.content.tripadvisor.com/api/v1/location/1335238/details?key=[XXX]
//{
//  "location_id": "1335238",
//  "name": "La Pigeot",
//  "web_url": "https://www.tripadvisor.com/Restaurant_Review-g187244-d1335238-Reviews-La_Pigeot-Valbonne_French_Riviera_Cote_d_Azur_Provence_Alpes_Cote_d_Azur.html?m=66827",
//  "address_obj": {
//    "street1": "16 rue Alexis Julien",
//    "street2": "",
//    "city": "Valbonne",
//    "country": "France",
//    "postalcode": "06560",
//    "address_string": "16 rue Alexis Julien, 06560 Valbonne France"
//  },
//  "ancestors": [
//    {
//      "level": "City",
//      "name": "Valbonne",
//      "location_id": "187244"
//    },
//    {
//      "level": "Region",
//      "name": "French Riviera - Cote d'Azur",
//      "location_id": "187216"
//    },
//    {
//      "level": "Region",
//      "name": "Provence-Alpes-Cote d'Azur",
//      "location_id": "187208"
//    },
//    {
//      "level": "Country",
//      "name": "France",
//      "location_id": "187070"
//    }
//  ],
//  "latitude": "43.642227",
//  "longitude": "7.009143",
//  "timezone": "Europe/Paris",
//  "phone": "+33 4 93 12 17 53",
//  "website": "http://www.restaurant-lapigeot.com",
//  "write_review": "https://www.tripadvisor.com/UserReview-g187244-d1335238-La_Pigeot-Valbonne_French_Riviera_Cote_d_Azur_Provence_Alpes_Cote_d_Azur.html?m=66827",
//  "ranking_data": {
//    "geo_location_id": "187244",
//    "ranking_string": "#4 of 81 Places to Eat in Valbonne",
//    "geo_location_name": "Valbonne",
//    "ranking_out_of": "81",
//    "ranking": "4"
//  },
//  "rating": "4.0",
//  "rating_image_url": "https://www.tripadvisor.com/img/cdsi/img2/ratings/traveler/4.0-66827-5.svg",
//  "num_reviews": "623",
//  "review_rating_count": {
//    "1": "22",
//    "2": "29",
//    "3": "52",
//    "4": "200",
//    "5": "320"
//  },
//  "subratings": {
//    "0": {
//      "name": "rate_food",
//      "localized_name": "Food",
//      "rating_image_url": "https://static.tacdn.com/img2/ratings/traveler/ss4.5.svg",
//      "value": "4.5"
//    },
//    "1": {
//      "name": "rate_atmosphere",
//      "localized_name": "Atmosphere",
//      "rating_image_url": "https://static.tacdn.com/img2/ratings/traveler/ss4.0.svg",
//      "value": "4.0"
//    },
//    "2": {
//      "name": "rate_service",
//      "localized_name": "Service",
//      "rating_image_url": "https://static.tacdn.com/img2/ratings/traveler/ss4.5.svg",
//      "value": "4.5"
//    },
//    "3": {
//      "name": "rate_value",
//      "localized_name": "Value",
//      "rating_image_url": "https://static.tacdn.com/img2/ratings/traveler/ss3.5.svg",
//      "value": "3.5"
//    }
//  },
//  "photo_count": "125",
//  "see_all_photos": "https://www.tripadvisor.com/Restaurant_Review-g187244-d1335238-m66827-Reviews-La_Pigeot-Valbonne_French_Riviera_Cote_d_Azur_Provence_Alpes_Cote_d_Azur.html#photos",
//  "price_level": "$$ - $$$",
//  "hours": {
//    "periods": [
//      {
//        "open": {
//          "day": 1,
//          "time": "1900"
//        },
//        "close": {
//          "day": 1,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 2,
//          "time": "1900"
//        },
//        "close": {
//          "day": 2,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 3,
//          "time": "1200"
//        },
//        "close": {
//          "day": 3,
//          "time": "1400"
//        }
//      },
//      {
//        "open": {
//          "day": 3,
//          "time": "1900"
//        },
//        "close": {
//          "day": 3,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 4,
//          "time": "1200"
//        },
//        "close": {
//          "day": 4,
//          "time": "1400"
//        }
//      },
//      {
//        "open": {
//          "day": 4,
//          "time": "1900"
//        },
//        "close": {
//          "day": 4,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 5,
//          "time": "1200"
//        },
//        "close": {
//          "day": 5,
//          "time": "1400"
//        }
//      },
//      {
//        "open": {
//          "day": 5,
//          "time": "1900"
//        },
//        "close": {
//          "day": 5,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 6,
//          "time": "0900"
//        },
//        "close": {
//          "day": 6,
//          "time": "1400"
//        }
//      },
//      {
//        "open": {
//          "day": 6,
//          "time": "1900"
//        },
//        "close": {
//          "day": 6,
//          "time": "2300"
//        }
//      },
//      {
//        "open": {
//          "day": 7,
//          "time": "1200"
//        },
//        "close": {
//          "day": 7,
//          "time": "1400"
//        }
//      },
//      {
//        "open": {
//          "day": 7,
//          "time": "1900"
//        },
//        "close": {
//          "day": 7,
//          "time": "2300"
//        }
//      }
//    ],
//    "weekday_text": [
//      "Monday: 19:00 - 23:00",
//      "Tuesday: 19:00 - 23:00",
//      "Wednesday: 12:00 - 14:00,  19:00 - 23:00",
//      "Thursday: 12:00 - 14:00,  19:00 - 23:00",
//      "Friday: 12:00 - 14:00,  19:00 - 23:00",
//      "Saturday: 09:00 - 14:00,  19:00 - 23:00",
//      "Sunday: 12:00 - 14:00,  19:00 - 23:00"
//    ]
//  },
//  "features": [
//    "Accepts Credit Cards",
//    "Outdoor Seating",
//    "Private Dining",
//    "Reservations",
//    "Seating",
//    "Serves Alcohol",
//    "Table Service",
//    "Wheelchair Accessible"
//  ],
//  "cuisine": [
//    {
//      "name": "moroccan",
//      "localized_name": "Moroccan"
//    },
//    {
//      "name": "mediterranean",
//      "localized_name": "Mediterranean"
//    },
//    {
//      "name": "middle_eastern",
//      "localized_name": "Middle Eastern"
//    }
//  ],
//  "category": {
//    "name": "restaurant",
//    "localized_name": "Restaurant"
//  },
//  "subcategory": [
//    {
//      "name": "sit_down",
//      "localized_name": "Sit down"
//    }
//  ],
//  "neighborhood_info": [],
//  "trip_types": [
//    {
//      "name": "business",
//      "localized_name": "Business",
//      "value": "18"
//    },
//    {
//      "name": "couples",
//      "localized_name": "Couples",
//      "value": "150"
//    },
//    {
//      "name": "solo",
//      "localized_name": "Solo travel",
//      "value": "4"
//    },
//    {
//      "name": "family",
//      "localized_name": "Family",
//      "value": "144"
//    },
//    {
//      "name": "friends",
//      "localized_name": "Friends getaway",
//      "value": "209"
//    }
//  ],
//  "awards": [
//        {
//          "award_type": "Travelers Choice Best of the Best",
//          "year": "2023",
//          "images": {
//            "tiny": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_bob_2023_L.png",
//            "small": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_bob_2023_L.png",
//            "large": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_bob_2023_L.png"
//          },
//          "categories": [
//            "FineDining"
//          ],
//          "display_name": "Travelers Choice Best of the Best"
//        },
//        {
//          "award_type": "Travelers Choice",
//          "year": "2023",
//          "images": {
//            "tiny": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_2023_L.png",
//            "small": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_2023_L.png",
//            "large": "https://static.tacdn.com/img2/travelers_choice/widgets/tchotel_2023_L.png"
//          },
//          "categories": [],
//          "display_name": "Travelers Choice"
//        }
//        ]
//}

struct TripAdvisorLocationDetailResult: Codable {
    let locationId: String
    let name: String
    let webUrl: URL
    let addressObj: TripAdvisorAddress
    let latitude: String
    let longitude: String
    let phone: String
    let website: URL
    let rankingData: TripAdvisorRankingData
    let rating: String
    let ratingImageUrl: URL
    let numReviews: String
    let reviewRatingCount: TripAdvisorReviewRatingCount
    let priceLevel: String
    let weekdayText: [String]
    let cuisine: [TripAdvisorCuisine]
    let awards: [TripAdvisorAward]
}

struct TripAdvisorRankingData: Codable {
    let geoLocationId: String
    let rankingString: String
    let geoLocationName: String
    let rankingOutOf: String
    let ranking: String
}

struct TripAdvisorReviewRatingCount: Codable {
    let one: String
    let two: String
    let three: String
    let four: String
    let five: String
    
    enum CodingKeys: String, CodingKey {
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
    }
}

struct TripAdvisorCuisine: Codable {
    let localizedName: String
}

struct TripAdvisorAwardImages: Codable {
    let tiny: URL
    let small: URL
    let large: URL
}

struct TripAdvisorAward: Codable {
    let awardType: String
    let year: String
    let images: TripAdvisorAwardImages
    let categories: [String]
    let displayName: String
}
