import 'dart:core';
import 'dart:html';
import 'dart:async';

void main() {
  sendRequest(window.location.origin)
    .then((Map<String, String> headers) {
    String serverDateStr = headers["Date"];
    DateTime localDate = new DateTime.now();
    DateTime serverDate = parseGTMString(serverDateStr);
    int diffHours = serverDate.hour - localDate.hour;
    int diffSecs = serverDate.second - localDate.second;
    if (diffHours >= 2) {
      window.console.error('Server time over computer time $diffHours');
    } else {
//      window.console.info('diff time $diffSecs');
    }
  });
}

Map<String, String> headerStrParser(String headerStr) {
  Map headerMap = new Map();
  headerStr.split('\n').forEach((String str) {
    if (str.isNotEmpty) {
      List<String> match = str.split(':');
      headerMap[match[0]] = match.sublist(1).join(':').trim();
    }
  });
  return headerMap;
}

Future sendRequest(String url) {
  var httpComplete = new Completer();
  var request = new HttpRequest();
  request.open('GET', url);
  request.addEventListener('readystatechange', (event) {
    event = event.currentTarget != null ? event.currentTarget : event;
    String headers = request.getAllResponseHeaders();
    if (httpComplete.isCompleted == false) {
      httpComplete.complete(headerStrParser(headers));
    }
  });
  request.send();
  return httpComplete.future;
}

int getMonth(String shortName) {
  final List<String> m = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  if (!m.contains(shortName)) {
    throw new ArgumentError.value(shortName, r'not a month short name');
  }
  return m.indexOf(shortName) + 1;
}

DateTime parseGTMString(String GTMStr) {
  if (GTMStr.contains('GTM')) {
    throw new ArgumentError(r'$GTMStr not a GMT time string');
  }
  Map map = GTMStr.replaceAll(',', '')
    .split(new RegExp(r'\s+'))
    .asMap();
  final String week = map[0];
  final int days = int.parse(map[1]);
  final int mon = getMonth(map[2]);
  final int yyyy = int.parse(map[3]);
  String hhmmss = map[4];
  String timeZone = map[5];
  List<String> hhmmssList = hhmmss.split(':');
  final int hh = int.parse(hhmmssList[0]);
  final int mm = int.parse(hhmmssList[1]);
  final int ss = int.parse(hhmmssList[2]);
  return new DateTime.utc(yyyy, mon, days, hh, mm, ss).toLocal();
}