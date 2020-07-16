import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'constant.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ortalama Hesaplama',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: TextTheme(
          body1: TextStyle(color: kBodyTextColor),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double _borderRadius = 24;
  int i = 0;
  String dersAdi;
  int dersKredi = 1;
  double dersHarfDegeri = 4;
  List<Ders> tumDersler;
  var formKey = GlobalKey<FormState>();
  double ortalama = 0;
  static int sayac = 0;
  List<Renkler> tumRenkler = rastgeleRenkOlustur();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumDersler = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState.validate()) {
            formKey.currentState.save();
          }
        },
        child: Icon(Icons.add),
      ),
      //üst bar
      body: Column(
        children: <Widget>[
          ClipPath(
            clipper: MyClipper(),
            child: Container(
              padding: EdgeInsets.only(left: 40, top: 30, right: 20),
              height: 330,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF3383CD),
                    Color(0xFF11249F),
                  ],
                ),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/background.png"),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Ortalama Hesaplama\n",
                              style: kHeadingTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              transform:
                                  Matrix4.translationValues(0.0, -20.0, 0.0),
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 20),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Ders Adını Giriniz",
                                  border: InputBorder.none,
                                ),
                                validator: (girilenDeger) {
                                  if (girilenDeger.length > 0) {
                                    return null;
                                  } else {
                                    return "Ders adı boş olamaz.";
                                  }
                                },
                                onSaved: (kaydedilecekDeger) {
                                  dersAdi = kaydedilecekDeger;
                                  setState(() {
                                    i++;
                                    tumDersler.add(Ders(
                                      dersAdi,
                                      dersHarfDegeri,
                                      dersKredi,
                                      tumRenkler[(i % 5)].startColor,
                                      tumRenkler[(i % 5)].endColor,
                                    ));
                                    ortalama = 0;
                                    ortalamayiHesapla();
                                  });
                                },
                              ),
                            ),

                            //row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                //kredi sayilari
                                Container(
                                  transform: Matrix4.translationValues(
                                      0.0, -20.0, 0.0),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border:
                                        Border.all(color: Color(0xFFE5E5E5)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      items: dersKredileriItems(),
                                      value: dersKredi,
                                      onChanged: (secilenKredi) {
                                        setState(() {
                                          dersKredi = secilenKredi;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                //harf degerleri
                                Container(
                                  transform: Matrix4.translationValues(
                                      0.0, -20.0, 0.0),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border:
                                        Border.all(color: Color(0xFFE5E5E5)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<double>(
                                        items: dersHarfDegerleriItems(),
                                        value: dersHarfDegeri,
                                        onChanged: (secilenHarf) {
                                          setState(() {
                                            dersHarfDegeri = secilenHarf;
                                          });
                                        }),
                                  ),
                                ), //harf degeleri container sonu
                              ],
                            ),

                            //ortalama gösterme kısmı
                            Container(
                              transform:
                                  Matrix4.translationValues(0.0, -20.0, 0.0),
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: tumDersler.length == 0
                                            ? "Lütfen ders ekleyin"
                                            : "Ortalamanız:",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                    TextSpan(
                                        text: tumDersler.length == 0
                                            ? " "
                                            : " ${ortalama.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                ),
                              ),
                            ),

                             //ortalama gösterme kısmı
                            Container(
                              transform:
                              Matrix4.translationValues(0.0, -20.0, 0.0),
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: "by emrearik",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.white))
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          //DİNAMİK LİSTE TUTAN CONTAİNER
          Expanded(
            child: Container(
              child: Container(
                transform: Matrix4.translationValues(0.0, -55.0, 0.0),
                child: ListView.builder(
                  primary: true,
                  itemCount: tumDersler.length,
                  itemBuilder: _listeElemanlariniOlustur,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> dersKredileriItems() {
    List<DropdownMenuItem<int>> krediler = [];
    for (int i = 1; i <= 10; i++) {
      krediler.add(DropdownMenuItem<int>(
          value: i, child: Text("$i Kredi", style: TextStyle(fontSize: 20))));
    }
    return krediler;
  }

  List<DropdownMenuItem<double>> dersHarfDegerleriItems() {
    List<DropdownMenuItem<double>> harfler = [];
    harfler.add(DropdownMenuItem(
      child: Text("AA", style: TextStyle(fontSize: 20)),
      value: 4,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("BA", style: TextStyle(fontSize: 20)),
      value: 3.5,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("BB", style: TextStyle(fontSize: 20)),
      value: 3,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("CB", style: TextStyle(fontSize: 20)),
      value: 2.5,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("CC", style: TextStyle(fontSize: 20)),
      value: 2,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("DC", style: TextStyle(fontSize: 20)),
      value: 1.5,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("DD", style: TextStyle(fontSize: 20)),
      value: 1,
    ));
    harfler.add(DropdownMenuItem(
      child: Text("FF", style: TextStyle(fontSize: 20)),
      value: 0,
    ));

    return harfler;
  }

  Widget _listeElemanlariniOlustur(BuildContext context, int index) {
    sayac++;
    return Dismissible(
      key: Key(sayac.toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          tumDersler.removeAt(index);
          ortalamayiHesapla();
        });
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Stack(
            children: <Widget>[
              Container(
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    gradient: LinearGradient(
                      colors: [
                        tumDersler[index].startColor,
                        tumDersler[index].endColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tumDersler[index].endColor,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]),
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size(100, 150),
                    painter: CustomCardShapePainter(
                      _borderRadius,
                      tumDersler[index].startColor,
                      tumDersler[index].endColor,
                    ),
                  )),
              Positioned.fill(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Image.asset(
                        'assets/icon.png',
                        color: Colors.white,
                        height: 48,
                        width: 48,
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tumDersler[index].ad,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                tumDersler[index].kredi.toString() + " Kredi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Avenir',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            tumDersler[index].harfDegeri.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void ortalamayiHesapla() {
    double toplamNot = 0;
    double toplamKredi = 0;

    for (var oAnkiDers in tumDersler) {
      var kredi = oAnkiDers.kredi;
      var harfDegeri = oAnkiDers.harfDegeri;

      toplamNot = toplamNot + (harfDegeri * kredi);
      toplamKredi += kredi;
    }
    ortalama = toplamNot / toplamKredi;
  }

/*
  Color rastgeleRenkOlustur() {
    String startColor;
    String endColor;

    
  }
  */
}

class Ders {
  String ad;
  double harfDegeri;
  int kredi;
  Color startColor;
  Color endColor;

  Ders(this.ad, this.harfDegeri, this.kredi, this.startColor, this.endColor);
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Renkler {
  final Color startColor;
  final Color endColor;

  Renkler(this.startColor, this.endColor);
}

List<Renkler> rastgeleRenkOlustur() {
  List<Renkler> renkler = [];
  renkler.add(Renkler(Color(0xffFFB157), Color(0xffFFA057)));
  renkler.add(Renkler(Color(0xff6DC8F3), Color(0xff73A1F9)));
  renkler.add(Renkler(Color(0xffFF5B95), Color(0xffF8556D)));
  renkler.add(Renkler(Color(0xffD76EF5), Color(0xff8F7AFE)));
  renkler.add(Renkler(Color(0xff42E695), Color(0xff3BB2B8)));
  return renkler;
}

class CustomCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 24.0;
    var paint = Paint();
    paint.shader = ui.Gradient.linear(
        Offset(0, 0), Offset(size.width, size.height), [
      HSLColor.fromColor(startColor).withLightness(0.8).toColor(),
      endColor
    ]);

    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
