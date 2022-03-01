import 'package:authentication_repository/authentication_repository.dart';
import 'package:biplus_media/src/app/bloc/app_bloc.dart';
import 'package:biplus_media/src/configs/app_theme.dart';
import 'package:biplus_media/src/helpers/native_helper.dart';
import 'package:biplus_media/src/helpers/route_helper.dart';
import 'package:biplus_media/src/pages/about/view/about_page.dart';
import 'package:biplus_media/src/pages/download/view/download_page.dart';
import 'package:biplus_media/src/pages/listing/view/listing_page.dart';
import 'package:biplus_media/src/pages/now_playing/view/now_playing_page.dart';
import 'package:biplus_media/src/pages/playlists/view/playlists_page.dart';
import 'package:biplus_media/src/pages/recent_played/view/recently_played_page.dart';
import 'package:biplus_media/src/pages/home/view/home_page.dart';
import 'package:biplus_media/src/pages/setting/view/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class App extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  static AppView appView = const AppView();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AppBloc(
            authenticationRepository: _authenticationRepository,
          )),
          // BlocProvider(create: (_) => BottomTabBloc()),
          // BlocProvider(create: (_) => DrawerBloc()),
        ],
        child: appView,
      )
    );
  }

  static of(BuildContext context) => context.findAncestorStateOfType<_AppViewState>()!;
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  _AppViewState createState() => _AppViewState();

  static _AppViewState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppViewState>()!;
}

class _AppViewState extends State<AppView> {
  Locale _locale = const Locale('en', '');

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      callIntent();
    }
    final String lang =
    Hive.box('settings').get('lang', defaultValue: 'English') as String;
    final Map<String, String> codes = {
      'English': 'en',
      'Vietnamese': 'vi'
    };
    _locale = Locale(codes[lang]!);
    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
  }

  Future<void> callIntent() async {
    await NativeHelper.handleIntent();
  }

  Widget initialPage() {
    // return kIsWeb ? WebHomePage() : const HomePage();
    return kIsWeb ? const HomePage() : const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.themeMode == ThemeMode.dark
            ? Colors.black38
            : Colors.white,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return RefreshConfiguration(
        headerBuilder: () => const WaterDropHeader(),        // Configure the default header indicator. If you have the same header indicator for each page, you need to set this
        footerBuilder:  () => const ClassicFooter(),        // Configure default bottom indicator
        headerTriggerDistance: 80.0,        // header trigger refresh trigger distance
        springDescription: const SpringDescription(stiffness: 170, damping: 16, mass: 1.9), // custom spring back animate,the props meaning see the flutter api
        maxOverScrollExtent :100, //The maximum dragging range of the head. Set this property if a rush out of the view area occurs
        maxUnderScrollExtent:0, // Maximum dragging range at the bottom
        enableScrollWhenRefreshCompleted: true, //This property is incompatible with PageView and TabBarView. If you need TabBarView to slide left and right, you need to set it to true.
        enableLoadingWhenFailed : true, //In the case of load failure, users can still trigger more loads by gesture pull-up.
        hideFooterWhenNotFull: false, // Disable pull-up to load more functionality when Viewport is less than one screen
        enableBallisticLoad: true, // trigger load more by BallisticScrollActivity
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'BiplusMedia',
          themeMode: AppTheme.themeMode,
          theme: AppTheme.lightTheme(context: context),
          darkTheme: AppTheme.darkTheme(context: context),
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
            Locale('vi', ''), // Vietnamese
          ],
          routes: {
            '/': (context) => initialPage(),
            '/setting': (context) => const SettingPage(),
            '/about': (context) => const AboutPage(),
            '/playlists': (context) => const PlaylistsPage(),
            '/nowPlaying': (context) => const NowPlayingPage(),
            '/recent': (context) => const RecentlyPlayedPage(),
            '/downloads': (context) => const DownloadsPage(),
            '/favorite': (context) => const ListingPage(type: ListingType.favorite, title: "Radio Yêu thích"),
          },
          onGenerateRoute: (RouteSettings settings) {
            return RouteHelper().handleRoute(settings.name);
          },
        )
    );
  }
}

