import 'package:flutter/material.dart';
import 'package:emarsys_sdk/emarsys_sdk.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO: Replace YOUR_APP_CODE with your app code
  await initEmarsys('YOUR_APP_CODE');

  // If a private DNS provider is used, this method will end up in a infinite loop
  // It will not catch any exception, so it will not be able to handle the error
  // Consequently, the app will not start and lunch the MyApp widget if we await this method call
  await setPushSendingEnabled(false);

  runApp(const MyApp());
}


Future<void> initEmarsys(String appCode) async {
  try {
    debugPrint('🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀 Emarsys: setup started');
    await Emarsys.setup(
      EmarsysConfig(
        applicationCode: appCode,
        androidVerboseConsoleLoggingEnabled: true,
      ),
    );
    debugPrint('✅✅✅✅✅✅✅✅✅✅ Emarsys: setup is done');
  } catch (e) {
    debugPrint('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 Emarsys: setup failed');
  }
}

Future<void> setPushSendingEnabled(bool isEnabled) async {
  try {
    debugPrint('🧬🧬🧬🧬🧬🧬🧬🧬🧬🧬 Emarsys: calling pushSendingEnabled with $isEnabled');
    await Emarsys.push.pushSendingEnabled(isEnabled);
    debugPrint('✅✅✅✅✅✅✅✅✅✅ Emarsys: pushSendingEnabled successfully disabled');
  } catch (e) {
    // This method will not catch any exception, in case of a private DNS provider configuration
    debugPrint('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 Emarsys: pushSendingEnabled failed');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tchibo Emarsys Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
