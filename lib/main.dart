import 'package:dragonpuppyfun/cgame.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.fullScreen();
  Flame.device.setPortraitUpOnly();
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
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.pink)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
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
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Art by Cadence - 9 yrs old\nMusic by Annika - 5yrs old',
                  // style: GoogleFonts.andika(
                  //     textStyle: TextStyle(
                  //         color: Colors.pinkAccent,
                  //         fontSize: 16,
                  //         fontFamily: 'Helvetica',
                  //         fontWeight: FontWeight.bold)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.background),
                onPressed: () {
                  CGame game = CGame();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameWidget(game: game)),
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
      ),
    );
  }
}
