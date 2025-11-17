import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/repositories/division_repository.dart';

class GetDivisionByIdUseCase {
  final DivisionRepository repository;

  GetDivisionByIdUseCase(this.repository);

  Future<Division> execute(int id) {
    return repository.getById(id);
  }
}
