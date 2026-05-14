import 'dart:async';

abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> add(T item);
  Future<T> update(T item);
  Future<bool> delete(String id);
}

class RepositoryResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  RepositoryResponse.success(this.data)
      : error = null,
        isSuccess = true;

  RepositoryResponse.error(this.error)
      : data = null,
        isSuccess = false;
}