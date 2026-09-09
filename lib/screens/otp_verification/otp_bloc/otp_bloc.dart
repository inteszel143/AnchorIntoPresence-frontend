import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../../../common/local_storage.dart';
import '../../../utils/global.dart' as globals;
import 'otp_event.dart';
import 'otp_state.dart';

class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  Timer? _timer;
  int _remainingSeconds = 30;

  OtpVerificationBloc() : super(OtpVerificationInitial()) {
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResendOtp>(_onResendOtp);
    on<StartResendOtpTimer>(_onStartTimer);
    on<TickResendOtpTimer>(_onTick);
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<OtpVerificationState> emit,
  ) async {
    emit(OtpVerificationLoading());

    try {
      final response = await ApiService.verifyOtp(
        email: event.email,
        otp: event.otp,
      );

      final body = response['body'];

      if (response['statusCode'] == 200 && body['status'] == true) {
        final token = body['data'];

        bool? hasPending = await LocalStorage.getBool();
        if (hasPending != true) {
          emit(OtpVerificationSuccess());
          return;
        }

        final purchaseData = await LocalStorage.getPurchase();

        if (purchaseData == null) {
          emit(OtpVerificationSuccess());
          return;
        }

        await ApiService.sendPurchase(
          productId: purchaseData["productId"],
          purchaseId: purchaseData["purchaseId"],
          amount: purchaseData["amount"],
          purchaseDate: purchaseData["purchaseDate"],
          planType: purchaseData["planType"],
          currencySymbol: purchaseData["currencySymbol"],
          extraToken: token,
        );
        globals.isSubscribed = true;
        // If no exception thrown → success
        emit(OtpVerificationSuccess());
      } else {
        emit(OtpVerificationFailure(
          body['message'] ?? "OTP verification failed",
        ));
      }
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(OtpVerificationFailure(errorMessage));
    }
  }

  Future<void> _onResendOtp(
      ResendOtp event, Emitter<OtpVerificationState> emit) async {
    emit(OtpVerificationLoading());
    try {
      final response = await ApiService.resendOtp(email: event.email);
      final body = response['body'];

      if (response['statusCode'] == 200 && body['status'] == true) {
        emit(OtpResendSuccess(body['message'] ?? 'OTP resent successfully'));
        add(StartResendOtpTimer());
      } else {
        emit(
            OtpVerificationFailure(body['message'] ?? 'Failed to resend OTP.'));
      }
    } on SocketException catch (e) {
      emit(OtpVerificationFailure('Please check your internet connection'));
    } catch (e) {
      emit(OtpVerificationFailure('Failed to resend OTP.'));
    }
  }

  void _onStartTimer(
      StartResendOtpTimer event, Emitter<OtpVerificationState> emit) {
    _remainingSeconds = 30;
    _timer?.cancel();
    emit(OtpResendTimerRunning(_remainingSeconds));

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds < 0) {
        _timer?.cancel();
        add(TickResendOtpTimer(0));
      } else {
        add(TickResendOtpTimer(_remainingSeconds));
      }
    });
  }

  void _onTick(TickResendOtpTimer event, Emitter<OtpVerificationState> emit) {
    emit(OtpResendTimerRunning(event.remainingSeconds));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
