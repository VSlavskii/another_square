import 'dart:convert';
import 'package:another_square/square_models.dart';
import 'package:http/http.dart' as http;

///
/// The authentication service handles all the logic of
/// requesting auth token from the Square APIs.
///
class AuthenticationService {
  final String clientId;
  final String clientSecret;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String revocationEndpoint;
  TokenResponse? _lastTokenResponse;

  AuthenticationService(
      {required this.clientId,
      required this.clientSecret,
      required this.authorizationEndpoint,
      required this.tokenEndpoint,
      required this.revocationEndpoint});

  /// Returns an authorization URL to be used in a web for to allow the
  /// user to authorize the application.
  String getAuthorizationPageUrl(
      {required List<Scope> scopes, required String state}) {
    Uri authUri = Uri.parse(authorizationEndpoint);
    authUri = _appendQueryParamsToUri(authUri, {
      "client_id": clientId,
      "scope": scopes.map((e) => e.scope).join(" "),
      "session": "False",
      "state": state,
      //"redirect_uri": redirectUrl,
      //"response_type": "code",
    });
    return authUri.toString();
  }

  ///
  /// Obtains the access token from the authorization code.
  ///
  Future<TokenResponse> getAuthToken(
      {required String code, required String redirectUrl}) async {
    var credentials = "$clientId:$clientSecret";
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(credentials);

    Map<String, String> headers = {
      "Authorization": "Basic " + encoded,
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    Map<String, String> body = {
      "code": code,
      "client_id": clientId,
      "client_secret": clientSecret,
      "redirect_uri": redirectUrl,
      "grant_type": "authorization_code"
    };

    Uri tokenUri = Uri.parse(tokenEndpoint);

    //print("tokenUri $tokenUri}");
    final response = await http.post(tokenUri, body: body, headers: headers);

    if (response.statusCode == 200) {
      //print (response.body);
      _lastTokenResponse = TokenResponse.fromJson(jsonDecode(response.body));
      return _lastTokenResponse!;
    } else {
      //print(response.body);
      throw TokenRequestFailedException(response.statusCode, response.body);
    }
  }

  ///
  /// Refreshes the authorization token.
  ///
  Future<TokenResponse> refreshToken({String refreshToken = ""}) async {
    if (refreshToken.isEmpty) {
      refreshToken = _lastTokenResponse?.refreshToken ?? "";
    }

    var credentials = "$clientId:$clientSecret";
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(credentials);

    Map<String, String> headers = {
      "Authorization": "Basic " + encoded,
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    Map<String, String> body = {
      "client_id": clientId,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "client_secret": clientSecret
    };

    Uri tokenUri = Uri.parse(tokenEndpoint);

    //print("tokenUri $tokenUri}");
    final response = await http.post(tokenUri, body: body, headers: headers);

    if (response.statusCode == 200) {
      //print (response.body);
      _lastTokenResponse = TokenResponse.fromJson(jsonDecode(response.body));
      return _lastTokenResponse!;
    } else {
      //print(response.body);
      throw TokenRequestFailedException(response.statusCode, response.body);
    }
  }

  Uri _appendQueryParamsToUri(Uri uri, Map<String, String> queryParameters) {
    uri = Uri(
        scheme: uri.scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.port,
        path: uri.path,
        //pathSegments: authUri.pathSegments,
        query: uri.query,
        //fragment: uri.fragment,
        queryParameters: queryParameters);

    return uri;
  }

  ///
  /// Returns the cached token if available
  ///
  TokenResponse? getCachedToken() {
    return _lastTokenResponse;
  }
}

class TokenRequestFailedException implements Exception {
  final int statusCode;
  final String message;
  TokenRequestFailedException(this.statusCode, this.message);

  @override
  String toString() {
    return "Error: $statusCode: $message";
  }
}
