import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/repositories/division_repository.dart';

class GetDivisionsUseCase {
  final DivisionRepository repository;

  GetDivisionsUseCase(this.repository);

  Future<List<Division>> execute() {
    return repository.getAll();
  }
}
