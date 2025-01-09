import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

import 'package:mocker/domain/domain.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._userRepository) : super(UserState.empty());

  final UserRepository _userRepository;

  Future<void> signIn(String username, String password) async {
    try {
      final user = await _userRepository.signIn(username, password);
      final devices = await _userRepository.getDevices(user.userId);
      emit(UserState(user: user, devices: devices));
    } on UserException catch (_) {
      emit(UserState.empty());
    } catch (e) {
      emit(UserState.empty());
    }
  }

  Future<void> getDevices() async {
    try {
      final devices = await _userRepository.getDevices(state.user.userId);
      emit(state.copyWith(devices: devices));
    } on UserException catch (_) {
      emit(state.copyWith(devices: <Device>[]));
    } catch (e) {
      emit(state.copyWith(devices: <Device>[]));
    }
  }

  void signOut() {
    _userRepository.signOut();
    emit(UserState.empty());
  }
}

class UserState implements Equatable {
  final User user;
  final List<Device> devices;

  const UserState({
    required this.user,
    required this.devices,
  });

  factory UserState.empty() {
    return UserState(
      user: User.empty(),
      devices: <Device>[],
    );
  }

  UserState copyWith({
    User? user,
    List<Device>? devices,
  }) {
    return UserState(
      user: user ?? this.user,
      devices: devices ?? this.devices,
    );
  }

  @override
  List<Object?> get props => [user, devices];

  @override
  bool? get stringify => true;
}
