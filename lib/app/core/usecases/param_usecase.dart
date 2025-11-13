abstract class ParamUseCase<T, Params> {
  Future<T> execute(Params params);
}
