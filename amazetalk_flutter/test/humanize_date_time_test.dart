import 'package:amazetalk_flutter/utils/humanize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('less than a minute ago', () {
    final now = DateTime.now();
    final fiveSecondsAgo = now.subtract(Duration(seconds: 5));

    expect(humanizeDateTime(fiveSecondsAgo), '5 seconds ago');
  });

  test('exactly 1 second ago', () {
    final now = DateTime.now();
    final oneSecondAgo = now.subtract(Duration(seconds: 1));

    expect(humanizeDateTime(oneSecondAgo), '1 second ago');
  });

  test('less than an hour ago', () {
    final now = DateTime.now();
    final fortyFiveMinutesAgo = now.subtract(Duration(minutes: 45));

    expect(humanizeDateTime(fortyFiveMinutesAgo), '45 minutes ago');
  });

  test('exactly 1 minute ago', () {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));

    expect(humanizeDateTime(oneMinuteAgo), '1 minute ago');
  });

  test('less than a day ago', () {
    final now = DateTime.now();
    final fiveHoursAgo = now.subtract(Duration(hours: 5));

    expect(humanizeDateTime(fiveHoursAgo), '5 hours ago');
  });

  test('exactly 1 hour ago', () {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(Duration(hours: 1));

    expect(humanizeDateTime(oneHourAgo), '1 hour ago');
  });

  test('less than a week ago', () {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 3));

    expect(humanizeDateTime(threeDaysAgo), '3 days ago');
  });

  test('exactly 1 day ago', () {
    final now = DateTime.now();
    final oneDayAgo = now.subtract(Duration(days: 1));

    expect(humanizeDateTime(oneDayAgo), '1 day ago');
  });

  test('less than a month ago', () {
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(Duration(days: 10));

    expect(humanizeDateTime(tenDaysAgo), '1 week ago');
  });

  test('exactly 1 month ago', () {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(Duration(days: 30));

    expect(humanizeDateTime(oneMonthAgo), '1 month ago');
  });

  test('less than a year ago', () {
    final now = DateTime.now();
    final sixMonthsAgo =
        now.subtract(Duration(days: 180)); // Approx. six months
    expect(humanizeDateTime(sixMonthsAgo), '6 months ago');
  });

  test('exactly 1 year ago', () {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(Duration(days: 365));

    expect(humanizeDateTime(oneYearAgo), '1 year ago');
  });

  test('more than a year ago', () {
    final now = DateTime.now();
    final twoYearsAgo = now.subtract(Duration(days: 730)); // Approx. 2 years
    expect(humanizeDateTime(twoYearsAgo), '2 years ago');
  });
}
