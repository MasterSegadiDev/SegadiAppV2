import 'package:dio/dio.dart';
import 'package:segadi/features/auth/domain/repositories/auth_repository.dart';

// class AuthInterceptor extends Interceptor {
//   final AuthRepository repository;

//   AuthInterceptor({
//     required this.repository,
//   });

//   @override
//   void onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     if (err.response?.statusCode == 401) {
//       final refreshToken = await getRefreshToken();

//       final result = await repository.refresh(
//         refreshToken,
//       );

//       result.fold(
//         (failure) {
//           return handler.next(err);
//         },
//         (token) async {
//           await saveToken(token);

//           final retryResponse = await retryRequest(
//             err.requestOptions,
//             token.accessToken,
//           );

//           return handler.resolve(retryResponse);
//         },
//       );
//     }

//     return handler.next(err);
//   }
// }

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    return handler.next(options);
  }
}
