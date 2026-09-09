import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';

import '../home_model.dart';

/// Base class for all home page states
abstract class HomePageState {}

/// Initial state before any data is loaded
class HomePageInitialState extends HomePageState {}

/// Loading state while fetching data
class HomePageLoadingState extends HomePageState {}

/// Success state with all home page data
class HomePageLoadedState extends HomePageState {
  final ProfileDataModel profileData;
  final HomePageDataModel homePageData;
  final List<RecentlyPlayedActivity> recentlyPlayedData;

  HomePageLoadedState({
    required this.profileData,
    required this.homePageData,
    this.recentlyPlayedData = const [],
  });
}

/// Error state with error message
class HomePageErrorState extends HomePageState {
  final String errorMessage;

  HomePageErrorState(this.errorMessage);
}

/// State when no data is available
class HomePageNoDataState extends HomePageState {
  final String message;

  HomePageNoDataState({this.message = 'No Data Found'});
}
