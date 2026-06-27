class PaginationModel<T> {
  final int code;
  final String message;
  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;
  final int? total;
  final List<T> data;

  PaginationModel({
    required this.code,
    required this.message,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalItems,
    this.total,
    required this.data,
  });
}
