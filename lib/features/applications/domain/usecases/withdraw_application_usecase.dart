import '../repositories/application_repository.dart';

class WithdrawApplicationUseCase {
  final ApplicationRepository repository;

  WithdrawApplicationUseCase(this.repository);

  Future<void> call(String applicationId) {
    return repository.withdrawApplication(applicationId);
  }
}
