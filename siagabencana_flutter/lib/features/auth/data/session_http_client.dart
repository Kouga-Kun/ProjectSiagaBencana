import 'package:http/http.dart' as http;

import 'session_http_client_io.dart'
    if (dart.library.js_interop) 'session_http_client_web.dart'
    as platform;

http.Client createSessionHttpClient() => platform.createSessionHttpClient();
