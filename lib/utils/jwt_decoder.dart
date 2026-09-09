import 'package:jwt_decoder/jwt_decoder.dart';

Map<String, dynamic>? jwtDecodedToken(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  } catch (e) {
    return null;
  }
}
