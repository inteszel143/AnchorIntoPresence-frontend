import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../../../common/local_storage.dart';
import '../../../utils/global.dart' as globals;
import '../../dashboard/home_model.dart';
import 'signin_event.dart';
import 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  SigninBloc() : super(SigninInitial()) {
    on<SigninSubmitted>(_onSigninSubmitted);
    on<SocialSigninSubmitted>(_onSocialSigninSubmitted);
  }

  Future<void> _onSigninSubmitted(
      SigninSubmitted event, Emitter<SigninState> emit) async {
    emit(SigninLoading());

    try {
      final fcmToken = await LocalStorage.getFCMToken();
      print('fcm:$fcmToken');
      final data = await ApiService.login(
        email: event.email,
        password: event.password,
        fcmToken: fcmToken,
      );
      await LocalStorage.saveToken(data.token);
      print('data:${data.data}');
      if (data.data?.email != null) {
        final userProfileFuture = ApiService.fetchProfileData(data.token);
        final results = await Future.wait([userProfileFuture]);
        final profileData = results[0];
        globals.alreadyPurchasedProductId = profileData.productId ?? '';
        globals.isSubscribed = profileData.subscriptionStatus == 'active';
        await LocalStorage.clearPurchase();
        await LocalStorage.deleteBool();
        emit(SigninSuccess(
          data.token,
          data.data?.name,
          data.data?.image,
          data.isFirst ?? false,
        ));
      } else {
        print('message:${data.message}');
        emit(SigninFailure(
            data.message.isNotEmpty ? data.message : 'Login failed'));
      }
    } on SocketException {
      emit(SigninFailure('Please check your internet connection'));
    } catch (e) {
      emit(SigninFailure('Please check your internet connection'));
    }
  }

  Future<void> _onSocialSigninSubmitted(
      SocialSigninSubmitted event, Emitter<SigninState> emit) async {
    emit(SigninLoading());
    try {
      final fcmToken = await LocalStorage.getFCMToken();

      final data = await ApiService.socialLogin(
        email: event.email,
        socialId: event.socialId,
        loginMedium: event.loginMedium,
        fcmToken: fcmToken,
      );

      await LocalStorage.saveToken(data.token);
      if (data.data?.email != null) {
        final userProfileFuture = ApiService.fetchProfileData(data.token);
        final results = await Future.wait([userProfileFuture]);
        final profileData = results[0];
        globals.alreadyPurchasedProductId = profileData.productId ?? '';
        globals.isSubscribed = profileData.subscriptionStatus == 'active';
        emit(SocialSigninSuccess(
          data.token,
          data.data?.name,
          data.data?.image,
        ));
      }
    } on SocketException {
      emit(SigninFailure('Please check your internet connection'));
    } catch (e) {
      emit(SigninFailure('Please check your internet connection'));
    }
  }
}
