import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local storage.']);
}
