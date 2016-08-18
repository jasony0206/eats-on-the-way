# Eats On The Way

Eats On The Way is a Ruby on Rails API that helps you find restaurants along your travel path. In addition to restaurant information, it also provides detailed travel information.

## Features
### Search
#### Parameters
The endpoint supports GET requests, and takes 2 parameters:
* `origin`: address of the start location of your travel
* `destination`: address of the end location of your travel

#### Response
Given valid parameters, the endpoint will return a JSON response of the following structure:
```
[
  {
    "name": "Dino's Chicken and Burgers",
    "rating": 4.5,
    "review_count": 1551,
    "location": {
      "latitude": 34.047441,
      "longitude": -118.293926
    },
    "total_travel": {
      "distance": {
        "text": "16.5 mi",
        "value": 26510
      },
      "duration": {
        "text": "33 min",
        "value": 2015
      }
    },
    "to_restaurant": {
      "distance": {
        "text": "12.8 mi",
        "value": 20651
      },
      "duration": {
        "text": "21 mins",
        "value": 1251
      }
    },
    "from_restaurant": {
      "distance": {
        "text": "3.6 mi",
        "value": 5859
      },
      "duration": {
        "text": "13 mins",
        "value": 764
      }
    }
  },
  ...
]
```
`name`, `rating`, `review_count`, and `location` values are retrieved from Yelp, and data under `total_travel`, `to_restaurant`, and `from_restaurant` properties are obtained via Google Maps API.

### Implementation
This API is implemented using the following technologies:
* Ruby on Rails
* Grape Ruby Gem
* Google Maps Directions API
* Google Maps Distance Matrix API
* Yelp Search API

### TODO
[] Add search category parameter (e.g. food, active, American)
[] Include category (e.g. cuisine) data in the response
[] Include start_location and end_location in the response
[] More descriptive error reporting
[] Add Swagger documentation
