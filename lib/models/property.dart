class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int bedrooms;
  final int bathrooms;
  final int areaSqFt;
  final String status;
  final List<String> tags;
  final List<String> images;
  final Location location;
  final Agent agent;
  final DateTime dateListed;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    required this.status,
    required this.tags,
    required this.images,
    required this.location,
    required this.agent,
    required this.dateListed,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaSqFt: json['areaSqFt'] as int,
      status: json['status'] as String,
      tags: List<String>.from(json['tags'] as List),
      images: List<String>.from(json['images'] as List),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      agent: Agent.fromJson(json['agent'] as Map<String, dynamic>),
      dateListed: DateTime.parse(json['dateListed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqFt': areaSqFt,
      'status': status,
      'tags': tags,
      'images': images,
      'location': location.toJson(),
      'agent': agent.toJson(),
      'dateListed': dateListed.toIso8601String(),
    };
  }
}

class Location {
  final String address;
  final String city;
  final String state;
  final String zip;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zip: json['zip'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Agent {
  final String name;
  final String email;
  final String contact;

  Agent({
    required this.name,
    required this.email,
    required this.contact,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      name: json['name'] as String,
      email: json['email'] as String,
      contact: json['contact'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'contact': contact,
    };
  }
}

