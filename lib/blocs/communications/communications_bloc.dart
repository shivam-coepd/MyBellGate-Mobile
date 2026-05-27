import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/models/announcement.dart';
import 'package:mygate_coepd/repositories/communications_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CommunicationsEvent extends Equatable {
  const CommunicationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends CommunicationsEvent {
  final bool? isDraft;
  const LoadAnnouncements({this.isDraft});
  @override
  List<Object?> get props => [isDraft];
}

class LoadPolls extends CommunicationsEvent {
  final bool? isActive;
  const LoadPolls({this.isActive});
  @override
  List<Object?> get props => [isActive];
}

class VoteOnPoll extends CommunicationsEvent {
  final String pollId;
  final String optionId;
  const VoteOnPoll(this.pollId, this.optionId);
  @override
  List<Object?> get props => [pollId, optionId];
}

class JoinGroup extends CommunicationsEvent {
  final String groupId;
  const JoinGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class LeaveGroup extends CommunicationsEvent {
  final String groupId;
  const LeaveGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CommunicationsState extends Equatable {
  const CommunicationsState();
  @override
  List<Object?> get props => [];
}

class CommunicationsInitial extends CommunicationsState {}

class CommunicationsLoading extends CommunicationsState {}

class AnnouncementsLoaded extends CommunicationsState {
  final List<Announcement> announcements;
  const AnnouncementsLoaded(this.announcements);
  @override
  List<Object?> get props => [announcements];
}

class PollsLoaded extends CommunicationsState {
  final List<Poll> polls;
  const PollsLoaded(this.polls);
  @override
  List<Object?> get props => [polls];
}

class VoteCast extends CommunicationsState {}

class GroupJoined extends CommunicationsState {}

class GroupLeft extends CommunicationsState {}

class CommunicationsError extends CommunicationsState {
  final String message;
  const CommunicationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class CommunicationsBloc
    extends Bloc<CommunicationsEvent, CommunicationsState> {
  final CommunicationsRepository _repository;

  CommunicationsBloc({CommunicationsRepository? repository})
      : _repository = repository ?? CommunicationsRepository(),
        super(CommunicationsInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<LoadPolls>(_onLoadPolls);
    on<VoteOnPoll>(_onVoteOnPoll);
    on<JoinGroup>(_onJoinGroup);
    on<LeaveGroup>(_onLeaveGroup);
  }

  Future<void> _onLoadAnnouncements(
      LoadAnnouncements event, Emitter<CommunicationsState> emit) async {
    emit(CommunicationsLoading());
    try {
      final items = await _repository.getAnnouncements(isDraft: event.isDraft);
      emit(AnnouncementsLoaded(items));
    } catch (e) {
      emit(CommunicationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadPolls(
      LoadPolls event, Emitter<CommunicationsState> emit) async {
    emit(CommunicationsLoading());
    try {
      final items = await _repository.getPolls(isActive: event.isActive);
      emit(PollsLoaded(items));
    } catch (e) {
      emit(CommunicationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onVoteOnPoll(
      VoteOnPoll event, Emitter<CommunicationsState> emit) async {
    emit(CommunicationsLoading());
    try {
      await _repository.voteOnPoll(event.pollId, event.optionId);
      emit(VoteCast());
    } catch (e) {
      emit(CommunicationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onJoinGroup(
      JoinGroup event, Emitter<CommunicationsState> emit) async {
    emit(CommunicationsLoading());
    try {
      await _repository.joinGroup(event.groupId);
      emit(GroupJoined());
    } catch (e) {
      emit(CommunicationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLeaveGroup(
      LeaveGroup event, Emitter<CommunicationsState> emit) async {
    emit(CommunicationsLoading());
    try {
      await _repository.leaveGroup(event.groupId);
      emit(GroupLeft());
    } catch (e) {
      emit(CommunicationsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
