import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../../../common/local_storage.dart';
import '../../../utils/global.dart' as globals;
import '../home_model.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home page data and state
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageInitialState()) {
    // Handle fetch home page data event
    on<FetchHomePageDataEvent>((event, emit) async {
      // Show loading state only for non-search actions
      if (!(event.isSearch ?? false)) {
        emit(HomePageLoadingState());
      }

      try {
        // Retrieve stored token
        final token = await LocalStorage.getToken() ?? '';

        // Fetch all required data in parallel
        final profileFuture = _fetchProfileData(token);
        final homeDataFuture =
            _fetchHomeData(token, event.searchQuery, event.sortOrder);
        final recentlyPlayedFuture = _fetchRecentlyPlayed();

        // Wait for all futures to complete
        final results = await Future.wait(
          [profileFuture, homeDataFuture, recentlyPlayedFuture],
        );

        // Extract results from futures
        final profileData = results[0] as ProfileDataModel;
        final homePageData = results[1] as HomePageDataModel;
        final recentlyPlayed = results[2] as RecentlyPlayedResponse;

        // Update global user data
        globals.alreadyPurchasedProductId = profileData.productId ?? '';
        globals.userId = profileData.id ?? '';
        globals.userName = profileData.name ?? '';
        globals.userImage = profileData.image ?? '';
        final String? subscriptionStatus = profileData.subscriptionStatus;
        globals.isSubscribed = subscriptionStatus == 'active';

        // Emit success state with all data
        emit(HomePageLoadedState(
          profileData: profileData,
          homePageData: homePageData,
          recentlyPlayedData: recentlyPlayed.data,
        ));
      } catch (e) {
        // Emit error state on failure
        emit(HomePageErrorState('$e'));
      }
    });
  }

  /// Fetches user profile data from API
  Future<ProfileDataModel> _fetchProfileData(String token) async {
    final data = await ApiService.fetchProfileData(token);
    return data;
  }

  /// Fetches home page data with optional search and sorting
  Future<HomePageDataModel> _fetchHomeData(
    String token,
    String searchQuery,
    String sortOrder,
  ) async {
    final data = await ApiService.fetchHomeData(token, searchQuery, sortOrder);
    return data;
  }

  /// Fetches recently played items with fallback to empty response
  Future<RecentlyPlayedResponse> _fetchRecentlyPlayed() async {
    try {
      return await ApiService.fetchRecentlyPlayed();
    } catch (e) {
      // Return empty response on failure to prevent UI crash
      return RecentlyPlayedResponse.empty();
    }
  }
}
