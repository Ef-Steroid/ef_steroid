/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:quiver/strings.dart';

typedef MessageCallBack = void Function(MessageData data);

class MessageData {
  final Object sender;
  final Object? args;

  MessageData(this.sender, this.args);
}

class MessagingCenter {
  static final Map<String, StreamController<MessageData>> _messages = {};
  static final Map<String, StreamSubscription<MessageData>> _subscriptions = {};

  static void send(
    String messageKey,
    Object sender, {
    dynamic args,
  }) {
    _messages[messageKey]?.add(MessageData(sender, args));
  }

  static StreamSubscription subscribe(
    String messageKey,
    Object subscriber,
    MessageCallBack callBack,
  ) {
    assert(isNotBlank(messageKey), 'messageKey must not be empty');

    _createStreamCtrlByMessageKeyIfAbsent(messageKey);

    final String hashedKey = _getHashedKey(messageKey, subscriber);
    assert(
      !_subscriptions.containsKey(hashedKey),
      '''You cannot subscribe to the same event (messageKey) with same 
      subscriber, if you want to do so, please unsubscribe and resubscribe.''',
    );
    final subscription = _messages[messageKey]!.stream.listen(callBack);
    _subscriptions[hashedKey] = subscription;
    return subscription;
  }

  static Future<void> unsubscribe(String messageKey, Object subscriber) async {
    assert(isNotBlank(messageKey), 'messageKey must not be empty');

    final String hashedKey = _getHashedKey(messageKey, subscriber);
    final subscription = _subscriptions.remove(hashedKey);
    await subscription?.cancel();
  }

  static Future<void> unsubscribeAll() async {
    for (final e in _subscriptions.keys) {
      final subscription = _subscriptions.remove(e);
      await subscription?.cancel();
    }
  }

  /// Clean all streams and subscribers
  static Future<void> clean() async {
    final clearMessages = Future.forEach(_messages.entries,
        (MapEntry<String, StreamController<MessageData>> e) async {
      final streamCtrl = _messages.remove(e.key);
      await streamCtrl?.close();
    });

    await Future.wait([unsubscribeAll(), clearMessages]);
  }

  static String _getHashedKey(String messageKey, Object subscriber) {
    final bytes = utf8.encode(messageKey + subscriber.hashCode.toString());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static void _createStreamCtrlByMessageKeyIfAbsent(
    String messageKey,
  ) {
    _messages.putIfAbsent(
      messageKey,
      () => StreamController.broadcast(sync: true),
    );
  }
}
