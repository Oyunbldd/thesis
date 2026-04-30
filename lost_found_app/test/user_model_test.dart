import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/models/user_model.dart';

void main() {
  // ── fromMap ──────────────────────────────────────────────────────────────

  group('UserModel.fromMap', () {
    test('correctly parses all fields from a valid map', () {
      final map = {
        'id': 'user_001',
        'name': 'John Doe',
        'email': 'student@inf.elte.hu',
        'role': 'student',
      };

      final model = UserModel.fromMap(map);

      expect(model.id, 'user_001');
      expect(model.name, 'John Doe');
      expect(model.email, 'student@inf.elte.hu');
      expect(model.role, 'student');
    });

    test('falls back to default role "student" when role field is missing', () {
      final map = {
        'id': 'user_002',
        'name': 'Jane Doe',
        'email': 'jane@inf.elte.hu',
      };

      final model = UserModel.fromMap(map);

      expect(model.role, 'student');
    });
  });

  // ── toMap ────────────────────────────────────────────────────────────────

  group('UserModel.toMap', () {
    test('serializes all fields to correct map keys and values', () {
      const model = UserModel(
        id: 'user_001',
        name: 'John Doe',
        email: 'student@inf.elte.hu',
        role: 'student',
      );

      final map = model.toMap();

      expect(map['id'], 'user_001');
      expect(map['name'], 'John Doe');
      expect(map['email'], 'student@inf.elte.hu');
      expect(map['role'], 'student');
    });
  });
}
