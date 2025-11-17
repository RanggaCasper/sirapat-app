import '../entities/division.dart';

abstract class DivisionRepository {
  Future<List<Division>> getAll();
  Future<Division> getById(int id);
  Future<Division> create(String name, String? description);
  Future<Division> update(int id, String name, String? description);
  Future<bool> delete(int id);
}
