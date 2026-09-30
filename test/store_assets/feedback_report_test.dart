// Opt-in report captures using production widgets and fictional sample data.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_dashboard.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_state.dart';
import 'package:mindfully_evolve_app/screens/setting/setting_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import '../video_player_controls_test.dart' show FakeVideoPlatform;
import 'capture_test.dart' as fixtures;

void main() {
 testWidgets('capture nine client feedback report images', (tester) async {
  if (!const bool.fromEnvironment('CAPTURE_REPORT')) return;
  const out = '../output/client-feedback-report';
  const uiOnly = bool.fromEnvironment('UI_ONLY');
  final destination = uiOnly ? '$out/current-ui' : out;
  Directory(destination).createSync(recursive: true);
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});
  final oldHttp = HttpOverrides.current;
  final oldVideo = VideoPlayerPlatform.instance;
  HttpOverrides.global = fixtures.AssetHttp((await rootBundle.load('assets/images/onboarding/onboarding-mandala-subtle-light.png')).buffer.asUint8List());
  VideoPlayerPlatform.instance = FakeVideoPlatform();
  addTearDown(() { HttpOverrides.global = oldHttp; VideoPlayerPlatform.instance = oldVideo; });
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  for (final font in [('DM Sans','assets/fonts/DMSans/DMSans-Variable.ttf'),('Manrope','assets/fonts/Manrope/Manrope-Variable.ttf'),('MaterialIcons','fonts/MaterialIcons-Regular.otf')]) {
   await tester.runAsync((FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load);
  }
  Widget emptyHome() => fixtures.tab(SafeArea(child: HomeDashboard(
   state: HomePageLoadedState(profileData: fixtures.home.profileData, homePageData: fixtures.home.homePageData),
   onProfile: () {}, onSearch: () {}, onRecent: () {}, onNotifications: () {}, onActivity: (_) {}, onCategory: (_) {}, onResume: (_) {})),0);
  final captures = <String,Uint8List>{};
  for (final name in ['home','library','filters','search-anchor','search-pause','continue','empty','anchor','pause','community','track','settings']) {
   tester.view.physicalSize = const Size(430,944);
   final key = GlobalKey();
   final page = switch(name) {
    'home' || 'continue' => fixtures.homeWidget(),
    'empty' => emptyHome(),
    'community' => fixtures.community(),
    'track' => fixtures.tab(TrackOverview(state: TrackLoadedState(fixtures.summary)),3),
    'settings' => fixtures.tab(SettingScreen(isTab:true),4),
    _ => fixtures.library(),
   };
   await tester.pumpWidget(RepaintBoundary(key:key, child:MaterialApp(debugShowCheckedModeBanner:false,theme:AppTheme.light,home:MediaQuery(data:const MediaQueryData(size:Size(430,944),padding:EdgeInsets.only(top:44,bottom:24)),child:page))));
   await tester.runAsync(() async {
    await precacheImage(const AssetImage('assets/images/app-background-light.png'),key.currentContext!);
    await Future<void>.delayed(const Duration(milliseconds:200));
   });
   await tester.pumpAndSettle();
   if (['anchor','pause','filters'].contains(name)) {
    final label = name=='anchor'?'Daily Anchors':name=='pause'?'Daily Pauses':'Favorites';
    final chip=find.widgetWithText(ChoiceChip,label);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
   }
   if (name.startsWith('search-')) {
    await tester.enterText(find.byType(TextField), name=='search-anchor'?'daily anchor':'daily pause');
    await tester.pumpAndSettle();
   }
   if (name=='continue') {
    await tester.drag(find.byType(SingleChildScrollView).first,const Offset(0,-500));
    await tester.pumpAndSettle();
   }
   final providers=tester.widgetList<Image>(find.byType(Image)).map((i)=>i.image).toList();
   await tester.runAsync(() async { for(final p in providers) { await precacheImage(p,key.currentContext!); } });
   await tester.pumpAndSettle();
   expect(tester.takeException(),isNull);
   captures[name]=await fixtures.save(tester,key,'$out/.capture-$name.png',2);
   await tester.pumpWidget(const SizedBox());
  }
  final reports = [
   ('01-home-focus','Home stays focused on the daily ritual','DONE','Explore Meditations is removed from the top of Home.',['home']),
   ('02-library-navigation','Library replaces Meditate','DONE','Library appears alongside Home, Community, Track and Settings.',['library']),
   ('03-library-filters','All | Daily Anchors | Daily Pauses | Favorites','DONE','Library category filters and the selected Favorites view.',['library','filters']),
   ('04-library-search','Search Library identifies each content type','DONE','Search results are labeled Daily Anchor or Daily Pause.',['search-anchor','search-pause']),
   ('05-continue-listening','Resume started, unfinished Daily Anchors','DONE','Sample unfinished Anchors appear with their saved playback position.',['continue']),
   ('06-empty-continue','Hide Continue Listening when nothing is unfinished','DONE','Comparison: unfinished Anchors available / no resumable activities. Pauses are excluded by the eligibility rule.',['continue','empty']),
   ('07-duration','Duration belongs only to Daily Anchors','DONE','Compare the Anchor duration with the visual Pause card, which has no audio counter.',['anchor','pause']),
   ('08-tab-roles','Community, Track and Settings retain their roles','DONE','Community posts / personal tracking / account and preferences.',['community','track','settings']),
   ('09-today-only','Home must show only today’s Anchor and Pause','NEEDS ADJUSTMENT','Current Home accepts all published activities from the API; today-only selection is not enforced.',['home']),
  ];
  for(final report in reports) {
   tester.view.physicalSize=uiOnly ? Size(430.0 * report.$5.length,944) : const Size(1440,1250);
   final key=GlobalKey();
   if (uiOnly) {
    await tester.pumpWidget(RepaintBoundary(key:key,child:Directionality(textDirection:TextDirection.ltr,child:Row(children:[for(final name in report.$5) Expanded(child:Image.memory(captures[name]!,fit:BoxFit.fill))]))));
   } else {
   await tester.pumpWidget(MaterialApp(debugShowCheckedModeBanner:false,theme:AppTheme.light,home:RepaintBoundary(key:key,child:Scaffold(backgroundColor:const Color(0xFFF5F0E7),body:Padding(padding:const EdgeInsets.all(36),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('ANCHOR INTO PRESENCE  /  CLIENT FEEDBACK',style:const TextStyle(fontSize:16,letterSpacing:2)),
    const SizedBox(height:14),
    Text(report.$2,style:const TextStyle(fontSize:32,fontWeight:FontWeight.w700)),
    const SizedBox(height:10),
    Text(report.$3,style:TextStyle(fontSize:18,fontWeight:FontWeight.w700,color:report.$3=='DONE'?Colors.green.shade800:Colors.brown.shade800)),
    const SizedBox(height:8),Text(report.$4,style:const TextStyle(fontSize:19)),const SizedBox(height:24),
    Expanded(child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[for(final name in report.$5) Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Image.memory(captures[name]!,fit:BoxFit.contain)))])),
    const SizedBox(height:18),const Text('Current Flutter UI • Fictional sample data • Local verification, not a TestFlight capture',style:TextStyle(fontSize:15)),
   ]))))));
   }
   await tester.runAsync(() async {for(final name in report.$5) {await precacheImage(MemoryImage(captures[name]!),key.currentContext!);}});
   await tester.pumpAndSettle();
   expect(tester.takeException(),isNull);
   await fixtures.save(tester,key,'$destination/${report.$1}.png',uiOnly ? 2 : 1.5);
   await tester.pumpWidget(const SizedBox());
  }
  for(final name in captures.keys) {File('$out/.capture-$name.png').deleteSync();}
 });
}
