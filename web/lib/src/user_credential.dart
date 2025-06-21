// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// A UserCredential is returned from authentication requests such as
/// [createUserWithEmailAndPassword].
class UserCredential {
  UserCredential._(this._auth, this._delegate) {
    UserCredentialPlatform.verify(_delegate);
  }

  final FirebaseAuth _auth;
  final UserCredentialPlatform _delegate;

  /// Returns additional information about the user, such as whether they are a
  /// newly created one.
  AdditionalUserInfo? get additionalUserInfo => _delegate.additionalUserInfo;

  /// The users [AuthCredential].
  AuthCredential? get credential => _delegate.credential;

  /// Returns a [User] if available.
  User? get user {
    final delegateUser = _delegate.user;
    return delegateUser == null ? null : User._(_auth, delegateUser);
  }

  @override
  String toString() {
    return 'UserCredential('
        'additionalUserInfo: $additionalUserInfo, '
        'credential: $credential, '
        'user: $user)';
  }
}
