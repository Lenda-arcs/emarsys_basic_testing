import 'dart:async';

import 'package:emarsys_sdk/emarsys_sdk.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initEmarsys();
  // Init firebase, has to be done before initInjection!

  runApp(const MyApp());
}

Future<void> initEmarsys() async {
  try {
    debugPrint('🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀 Emarsys: setup started');
    await Emarsys.setup(
      EmarsysConfig(
        applicationCode: null,
        androidVerboseConsoleLoggingEnabled: true,
      ),
    );
    debugPrint('✅✅✅✅✅✅✅✅✅✅ Emarsys: setup is done');
  } catch (e) {
    debugPrint('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨 Emarsys: setup failed');
  }
}

//TODO: Replace with your App Code, Contact Field ID and Contact GUID
const String appCode = 'tchibo-beta';
const String productionFieldId = '12345678';
const String contactGUID = 'test-guid-12345';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint('APP CODE: ${Emarsys.config.applicationCode().toString()}');
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
  int contactFieldId = 0;
  String activeAppCode = "No App Code";
  String sdkVersion = "No SDK Version";
  String hardwareId = "No Hardware ID";
  String inboxMessagesCount = "No Messages";
  bool pushSendingEnabled = false;
  final TextEditingController _appCodeController = TextEditingController();
  final TextEditingController _contactIdController = TextEditingController();
  final TextEditingController _contactGuidController = TextEditingController();

  Future<void> _initEmarsysConfig({withChangeCode = false}) async {
    //call change app code only if requested
    if (withChangeCode) await _changeAppCode(appCode);

    final activeAppCode = await Emarsys.config.applicationCode();
    final contactFieldId = await Emarsys.config.contactFieldId();
    final sdkVersion = await Emarsys.config.flutterPluginVersion();
    final hardwareId = await Emarsys.config.hardwareId();

    setState(() {
      this.contactFieldId = contactFieldId ?? 0;
      this.activeAppCode = activeAppCode ?? "No App Code";
      this.sdkVersion = sdkVersion;
      this.hardwareId = hardwareId;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initEmarsysConfig(withChangeCode: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: IconButton(onPressed: _initEmarsysConfig, icon: const Icon(Icons.refresh)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(20),
              shadowColor: Colors.black54,
              child: Container(
                  width: 300,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          'Contact Field ID:  ${contactFieldId != 0 ? contactFieldId : "No Contact Field ID"}',
                        ),
                        Text('App Code: $activeAppCode'),
                        Text(
                          'Hardware ID: $hardwareId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('SDK Version: $sdkVersion'),
                      ],
                    ),
                  )),
            ),

            if (contactFieldId == 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                      controller: _contactIdController..text = productionFieldId.toString(),
                      decoration: const InputDecoration(hintText: 'Contact ID'),
                      initialValue: null,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                      controller: _contactGuidController..text = contactGUID,
                      decoration: const InputDecoration(hintText: 'Contact GUID'),
                      initialValue: null,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.all(8))),
                    onPressed: () => setContact(
                        _contactGuidController.text.isEmpty ? 0 : int.parse(_contactIdController.text),
                        _contactGuidController.text),
                    child: const Text('Set Contact'),
                  ),
                ],
              )
            ] else
              ElevatedButton(
                onPressed: _clearContact,
                child: const Text('Clear Contact'),
              ),
            //CHANGE application code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    controller: _appCodeController..text = appCode,
                    decoration: const InputDecoration(
                      hintText: 'App Code',
                    ),
                    initialValue: null,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _changeAppCode(_appCodeController.text),
                  child: const Text('Change App Code'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => setPushSendingEnabled(pushSendingEnabled = !pushSendingEnabled),
              child: const Text('Enable Push Sending'),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: _fetchMessages,
                  child: Text('${contactFieldId != 0 ? 'Fetch' : 'Fetch (no contact set)'} Inbox Messages'),
                ),
                Text('Inbox Messages Count: ${inboxMessagesCount.toString()}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> setContact(int id, String guid) async {
    try {
      debugPrint('Setting contact with $id and $guid');
      await Emarsys.setContact(id, guid);
      debugPrint('Successfully set contact with $id and $guid');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await _initEmarsysConfig();
    }
  }

  Future<void> _changeAppCode(String code) async {
    try {
      await Emarsys.config.changeApplicationCode(code);

      await Emarsys.push.registerAndroidNotificationChannels([
        NotificationChannel(
            id: "tchibo_default_channel",
            name: "Messages",
            description: "Important messages go into this channel",
            importance: NotificationChannel.IMPORTANCE_HIGH),
      ]);
      debugPrint('Change Application Code called with $code');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await _initEmarsysConfig();
    }
  }

  Future<void> _clearContact() async {
    try {
      await Emarsys.clearContact();
      debugPrint('Clear Contact called');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await _initEmarsysConfig();
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final messages = await Emarsys.messageInbox.fetchMessages();
      setState(() {
        inboxMessagesCount = messages.length.toString();
      });
      debugPrint('Fetch Messages called');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      await _initEmarsysConfig();
    }
  }

  Future<void> setPushSendingEnabled(bool isEnabled) async {
    try {
      debugPrint('Emarsys: calling pushSendingEnabled with $isEnabled');
      await Emarsys.push.pushSendingEnabled(isEnabled);
      debugPrint('Emarsys: pushSendingEnabled successfully set to $isEnabled');
      setState(() => pushSendingEnabled = isEnabled);
    } catch (e) {
      // This method will not catch any exception, in case of a private DNS provider configuration
      debugPrint('Emarsys: pushSendingEnabled failed');
    }
  }
}
