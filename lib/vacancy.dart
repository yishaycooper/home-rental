import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  var loading = true;
  Position? position;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  responseDuration() {
    Timer(Duration(seconds: 5), () {
      loading = false;
      setState(() {});
    });
  }

  getCurrentLocation() async {
    position = await determinePosition();
    setState(() {});
  }

  @override
  void initState() {
    responseDuration();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body:
        SafeArea(
          child: SizedBox.expand(
            child: Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
            child: Image.network("https://mms.businesswire.com/media/20220329005290/en/1403098/5/Home365.jpg")
                ),
                loading ? Container(
                    margin: EdgeInsets.only(bottom: 200),
                    child: CircularProgressIndicator()) :
                Expanded(
                flex: 4,
                child: CurrentLocationScreen(),
                ),
                loading ? SizedBox() :
                Expanded(
                  flex: 7,
                  child: ListView.builder
                    (
                      itemCount: vacancyInfo["data"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                                    children :[
                                      Expanded(
                                        flex: 22,
                                        child: Column(children: [

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Flexible(child: Text(vacancyInfo["data"][index]["address"]["he"]["street_name"] + " ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)),
                                            vacancyInfo["data"][index]["address"]["he"]["house_number"] != null ?
                                            FittedBox(child: Text(" " + vacancyInfo["data"][index]["address"]["he"]["house_number"] + " ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)) :
                                            FittedBox(child: Text(" &")),
                                            FittedBox(child: Text(vacancyInfo["data"][index]["address"]["he"]["city_name"] + " ",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)),
                                        ],),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FittedBox(child: Text("₪")),
                                            FittedBox(child: Text(vacancyInfo["data"][index]["price"].toString() + " ")),
                                            FittedBox(child: Text(":שכירות חודשית")),
                                        ],),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FittedBox(child: Text(":מידע נוסף")),
                                        ],),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FittedBox(child: Text(" " + vacancyInfo["data"][index]["additional_info"]["rooms"].toString() + " ")),
                                            FittedBox(child: Text(":מס' חדרים")),
                                        ],),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FittedBox(child: Text(" " + vacancyInfo["data"][index]["additional_info"]["bathrooms"].toString() + " ")),
                                            FittedBox(child: Text(":חדרי שירותים / אמבטיות")),
                                        ],),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // FittedBox(child: Text(vacancyInfo["data"][index]["property_type"])),
                                        ],),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FittedBox(child: Text(vacancyInfo["data"][index]["additional_info"]["floor"]["out_of"].toString())),
                                            FittedBox(child: Text("מתוך ")),
                                            FittedBox(child: Text(" " + vacancyInfo["data"][index]["additional_info"]["floor"]["on_the"].toString())),
                                            FittedBox(child: Text("קומה ")),
                                            FittedBox(child: Text(" - " + vacancyInfo["data"][index]["property_type"])),
                                            // FittedBox(child: Text(" - " + vacancyInfo["data"][index]["address"]["location"]["lat"].toString())),
                                            // FittedBox(child: Text(" - " + vacancyInfo["data"][index]["address"]["location"]["lon"].toString())),
                                          ],),

                                      ],),),
                                      Expanded(child: SizedBox()),
                                      Expanded(
                                          flex: 10,
                                          child: Column(
                                              children: <Widget>[ Image.network(vacancyInfo["data"][index]["thumbnail"],
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                fit: BoxFit.fill,
                                              ),
                                              Card(
                                                  child: position == null ? SizedBox() : Text(
                                                      (calculateDistance(vacancyInfo["data"][index]["address"]["location"]["lat"],
                                                        vacancyInfo["data"][index]["address"]["location"]["lon"],
                                                        position?.latitude, position?.longitude).toStringAsFixed(1) + " km" ),
                                                    style: TextStyle(color: Colors.black, fontSize: 14),
                                                    textAlign: TextAlign.left
                                                  ),
                                                ),
                                              ]
                                          )
                                      ),
                                      Expanded(child: SizedBox()),
                                    ],

                            ),
                            Divider()
                          ],
                        );
                      }
                  ),
                ),

              ],
            ),
      ),
        ),
      ),
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }


}

Map<String, dynamic> vacancyInfo = {
  "data": [
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 3.5,
        "floor": {
          "on_the": 0,
          "out_of": 2
        }
      },
      "price": 11800,
      "property_type": "דירת גן",
      "address": {
        "location": {
          "lat": 32.0626449,
          "lon": 34.7647233
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "3",
          "street_name": "החרמון",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "S1fUfq5y5",
      "created_at": "2022-02-16T15:03:38.311Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/ipfezsjxqv4a8ltvyygw"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 1,
        "floor": {
          "on_the": 1,
          "out_of": 3
        }
      },
      "price": 2700,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0487404,
          "lon": 34.791238
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "53",
          "street_name": "קמואל",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "HJY-JcnZq",
      "created_at": "2022-03-14T09:46:40.552Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/dpspmnvan1sdpybzifun"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 1.5,
        "floor": {
          "on_the": 8,
          "out_of": 8
        }
      },
      "price": 3600,
      "property_type": "דירת גג",
      "address": {
        "location": {
          "lat": 32.053052,
          "lon": 34.804499
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "78",
          "street_name": "הרב אלנקווה",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "Sy1kv_-N5",
      "search_date": "2022-05-26T09:16:11.834Z",
      "created_at": "2022-04-11T09:37:27.093Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/fmdnz9zdvis7ll2jjutb"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 4,
        "floor": {
          "on_the": 1,
          "out_of": 1
        }
      },
      "price": 8500,
      "property_type": "בית פרטי",
      "address": {
        "location": {
          "lat": 32.0440048,
          "lon": 34.8045377
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "43",
          "street_name": "בושם",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "rJ3i0xoX9",
      "created_at": "2022-04-06T11:51:00.281Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/qohugb7i7mta2ta7rcbh"
    },
    {
      "additional_info": {
        "bathrooms": 2,
        "rooms": 4,
        "floor": {
          "on_the": 12,
          "out_of": 25
        }
      },
      "price": 27000,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.100576,
          "lon": 34.7895405
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": null,
          "street_name": "שדרות לוי אשכול",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "By9-kBLUq",
      "created_at": "2022-05-09T07:13:05.716Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/ksorpowbgy2kyff2eenb"
    },
    {
      "additional_info": {
        "bathrooms": 2,
        "rooms": 3,
        "floor": {
          "on_the": 19,
          "out_of": 50
        }
      },
      "price": 10500,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0874381,
          "lon": 34.7969102
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "2",
          "street_name": "ניסים אלוני",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "Sk0ahawL9",
      "created_at": "2022-05-10T11:30:14.419Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/nsi1yqjcbxgh9heb4bts"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 2.5,
        "floor": {
          "on_the": 1,
          "out_of": 4
        }
      },
      "price": 3900,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0445128,
          "lon": 34.8064207
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "22",
          "street_name": "בושם",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "rJbVPg-w5",
      "created_at": "2022-05-17T10:21:28.608Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/oijouhfzko3vlxaywtzs"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 4,
        "floor": {
          "on_the": 0,
          "out_of": 7
        }
      },
      "price": 7500,
      "property_type": "דירת גן",
      "address": {
        "location": {
          "lat": 32.0523474,
          "lon": 34.8111076
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "58",
          "street_name": "מעפילי אגוז",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "BytvgLzD9",
      "created_at": "2022-05-18T10:54:25.393Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/srusr7wqwymh1w3aorvc"
    },
    {
      "additional_info": {
        "bathrooms": 2,
        "rooms": 5,
        "floor": {
          "on_the": 15,
          "out_of": 18
        }
      },
      "price": 7500,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0474707,
          "lon": 34.7943968
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": null,
          "street_name": "שתולים",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "rkY9nMzD5",
      "created_at": "2022-05-18T07:13:20.850Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/khixezu5madqvnozoup1"
    },
    {
      "additional_info": {
        "bathrooms": 1,
        "rooms": 5,
        "floor": {
          "on_the": 4,
          "out_of": 8
        }
      },
      "price": 11000,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.109968,
          "lon": 34.790787
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": null,
          "street_name": "יהודה בורלא",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "HJAX_pXv5",
      "created_at": "2022-05-19T13:37:41.795Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/cpratuhnwyxq9ia8flqb"
    },
    {
      "additional_info": {
        "bathrooms": 2,
        "rooms": 2.5,
        "floor": {
          "on_the": 2,
          "out_of": 2
        }
      },
      "price": 4500,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0526205,
          "lon": 34.7881804
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "24",
          "street_name": "דעואל",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "BkR3wj_Dq",
      "created_at": "2022-05-23T06:20:38.364Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/ntw1rug2pvwv2d9gggp5"
    },
    {
      "additional_info": {
        "bathrooms": 3,
        "rooms": 5,
        "floor": {
          "on_the": 46,
          "out_of": 48
        }
      },
      "price": 20000,
      "property_type": "דירה",
      "address": {
        "location": {
          "lat": 32.0781711,
          "lon": 34.7939465
        },
        "he": {
          "city_name": "תל אביב-יפו",
          "house_number": "144",
          "street_name": "דרך מנחם בגין",
          "neighborhood": "תל אביב-יפו"
        }
      },
      "id": "r1QfOYDD9",
      "created_at": "2022-05-22T09:53:14.529Z",
      "thumbnail": "https://res.cloudinary.com/onmap-prod/image/upload/w_350,h_264,q_auto,f_auto,c_fill/dlsxzu2xnwvj0w1bwpfg"
    }
  ]
};

