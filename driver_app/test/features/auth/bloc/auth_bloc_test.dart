import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';
import 'package:zeni_driver/features/auth/bloc/auth_bloc.dart';
import 'package:zeni_driver/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthBlocState>(
      'emits [AuthLoading, AuthOtpSent] when PhoneNumberSubmitted is added',
      build: () {
        when(() => mockAuthRepository.signInWithOtp(phone: '+1234567890'))
            .thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(PhoneNumberSubmitted('+1234567890')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthOtpSent>(),
      ],
    );
  });
}
