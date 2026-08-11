enum Status { loading, completed, error }

enum Flavor { dev, staging, prod }

enum UserType {
  user('user'),
  vendor('vendor');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserType.user,
    );
  }
}
