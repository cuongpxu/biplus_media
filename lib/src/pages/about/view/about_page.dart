import 'package:biplus_media/src/widgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width / 2,
            top: MediaQuery.of(context).size.width / 5,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                fit: BoxFit.fill,
                image: AssetImage(
                  'assets/icon-white-trans.png',
                ),
              ),
            ),
          ),
          const GradientContainer(
            child: null,
            opacity: true,
          ),
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
              title: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const SizedBox(
                        width: 150,
                        child:
                        Image(image: AssetImage('assets/ic_launcher.png')),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('v$appVersion'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.madeBy,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
