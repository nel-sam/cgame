// @dart=2.9
import 'package:dragonpuppyfun/cgame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Util flameUtil = Util();
  flameUtil.fullScreen();
  flameUtil.setOrientation(DeviceOrientation.portraitUp);

  //runApp(game.widget);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CGame',
      theme: ThemeData(
          primaryColor: Colors.purple[800],
          accentColor: Colors.pink,
          accentColorBrightness: Brightness.light),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'assets/images/ui/dragon_text.png',
                height: 100,
              ),
            ),
            Container(
              child: Image.asset(
                'assets/images/ui/puppy_text.png',
                height: 100,
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 50),
              child: Image.asset(
                'assets/images/ui/fun_text.png',
                height: 100,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.white),
              onPressed: () {
                CGame game = CGame();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => game.widget),
                );
              },
              child: Container(
                //padding: EdgeInsets.all(30),
                child: Image.asset('assets/images/ui/start_btn.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
