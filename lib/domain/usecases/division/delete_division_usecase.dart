import 'package:sirapat_app/domain/repositories/division_repository.dart';

class DeleteDivisionUsecase {
  final DivisionRepository repository;

  DeleteDivisionUsecase(this.repository);

  Future<bool> execute(int id) {
    return repository.delete(id);
  }
}
