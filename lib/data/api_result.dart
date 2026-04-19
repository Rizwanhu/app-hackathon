/// Structured result for Supabase-backed calls (success vs. user-safe error).
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      };

  String? get errorMessage => switch (this) {
        ApiFailure(:final message) => message,
        ApiSuccess() => null,
      };
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final String? code;
  const ApiFailure(this.message, {this.code});
}
