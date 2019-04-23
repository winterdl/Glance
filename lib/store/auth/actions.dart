import 'dart:async';

import 'package:reddigram/api/api.dart';
import 'package:reddigram/store/store.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<ReddigramState> authenticateUser(String code,
    [Completer completer]) {
  return (Store<ReddigramState> store) async {
    await redditRepository.retrieveAccessToken(code);

    final futures = <Future>[];

    futures.add(redditRepository
        .username()
        .then((username) => store.dispatch(SetUsername(username))));

    // todo(Albert221): authenticate to subscriptions database and then fetch:
    store.dispatch(fetchSubscribedSubreddits());

    final freshFeedCompleter = Completer();
    futures.add(freshFeedCompleter.future);
    store.dispatch(fetchFreshFeed(freshFeedCompleter));

    Future.wait(futures).whenComplete(() => completer?.complete());
  };
}

ThunkAction<ReddigramState> signUserOut([Completer completer]) {
  return (Store<ReddigramState> store) {
    redditRepository.clearTokens().then((_) {
      store.dispatch(SetUsername(null));
      store.dispatch(FetchedSubscribedSubreddits(['aww']));
      store.dispatch(fetchFreshFeed(completer));
    });
  };
}

class SetUsername {
  final String username;

  SetUsername(this.username);
}