import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/repositories/division_repository.dart';

class CreateDivisionParams {
  final String name;
  final String? description;

  CreateDivisionParams({required this.name, this.description});
}

class CreateDivisionUseCase {
  final DivisionRepository repository;

  CreateDivisionUseCase(this.repository);

  Future<Division> execute(CreateDivisionParams params) {
    return repository.create(params.name, params.description);
  }
}
