import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/repositories/division_repository.dart';

class UpdateDivisionParams {
  final int id;
  final String name;
  final String? description;

  UpdateDivisionParams({
    required this.id,
    required this.name,
    this.description,
  });
}

class UpdateDivisionUseCase {
  final DivisionRepository repository;

  UpdateDivisionUseCase(this.repository);

  Future<Division> execute(UpdateDivisionParams params) {
    return repository.update(params.id, params.name, params.description);
  }
}
